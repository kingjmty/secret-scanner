#!/usr/bin/env node
/**
 * secret-scanner / src/secret-scanner.js
 * Scans staged (or specified) files for API keys, tokens, and credentials
 * before they leak into a commit. Zero external dependencies.
 *
 * Usage:
 *   node src/secret-scanner.js --staged
 *   node src/secret-scanner.js --path src/
 *   node src/secret-scanner.js --install-hook
 */
'use strict';

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

function sh(cmd) {
  try {
    return execSync(cmd, { stdio: ['pipe', 'pipe', 'pipe'] }).toString().trim();
  } catch (e) {
    return '';
  }
}

// Each rule: name, regex, and a note on what it likely is
const RULES = [
  { name: 'AWS Access Key ID', re: /\bAKIA[0-9A-Z]{16}\b/g },
  { name: 'AWS Secret Access Key', re: /(?:aws_secret_access_key|secret[_-]?key)\s*[:=]\s*['"]?[A-Za-z0-9\/+=]{40}['"]?/gi },
  { name: 'GitHub Token', re: /\bgh[pousr]_[A-Za-z0-9]{36,}\b/g },
  { name: 'Generic API Key assignment', re: /\b(api[_-]?key|apikey|secret|token|password|passwd|pwd)\b\s*[:=]\s*['"][A-Za-z0-9\-_\/+=]{12,}['"]/gi },
  { name: 'Private Key block', re: /-----BEGIN (RSA |EC |OPENSSH |DSA |PGP )?PRIVATE KEY-----/g },
  { name: 'Slack Token', re: /\bxox[baprs]-[A-Za-z0-9-]{10,}\b/g },
  { name: 'Stripe Key', re: /\b(sk|pk)_(live|test)_[A-Za-z0-9]{16,}\b/g },
  { name: 'Google API Key', re: /\bAIza[0-9A-Za-z\-_]{35}\b/g },
  { name: 'JWT', re: /\beyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\b/g },
  { name: 'Generic high-entropy string in .env-like assignment', re: /^[A-Z0-9_]{4,}=[A-Za-z0-9\/+=]{24,}$/gm },
];

const IGNORE_PATTERNS = [/node_modules\//, /\.git\//, /package-lock\.json$/, /dist\//, /build\//];

function parseArgs(argv) {
  const args = { staged: false, path: null, installHook: false };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--staged') args.staged = true;
    else if (a === '--path') args.path = argv[++i];
    else if (a === '--install-hook') args.installHook = true;
    else if (a === '--help') args.help = true;
  }
  return args;
}

function stagedFiles() {
  const out = sh('git diff --cached --name-only --diff-filter=ACM');
  return out ? out.split('\n').filter(Boolean) : [];
}

function walk(dir) {
  const out = [];
  if (!fs.existsSync(dir)) return out;
  const stat = fs.statSync(dir);
  if (stat.isFile()) return [dir];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (IGNORE_PATTERNS.some((re) => re.test(full))) continue;
    if (entry.isDirectory()) out.push(...walk(full));
    else out.push(full);
  }
  return out;
}

function scanFile(filePath) {
  let content;
  try {
    content = fs.readFileSync(filePath, 'utf8');
  } catch (e) {
    return []; // binary or unreadable — skip
  }
  const findings = [];
  const lines = content.split('\n');

  RULES.forEach((rule) => {
    lines.forEach((line, idx) => {
      rule.re.lastIndex = 0;
      if (rule.re.test(line)) {
        findings.push({ file: filePath, line: idx + 1, rule: rule.name, snippet: line.trim().slice(0, 100) });
      }
    });
  });

  return findings;
}

function installHook() {
  const hookDir = path.join(process.cwd(), '.git', 'hooks');
  if (!fs.existsSync(hookDir)) {
    console.error('✗ No .git/hooks directory found. Run this inside a git repository.');
    process.exit(1);
  }
  const hookPath = path.join(hookDir, 'pre-commit');
  const hookScript = `#!/bin/sh\nnode "${path.join(process.cwd(), 'src', 'secret-scanner.js')}" --staged || exit 1\n`;
  fs.writeFileSync(hookPath, hookScript, { mode: 0o755 });
  fs.chmodSync(hookPath, 0o755);
  console.log(`✓ Installed pre-commit hook at ${hookPath}`);
}

function printHelp() {
  console.log(`secret-scanner — scan for leaked credentials before they leak

Usage:
  secret-scanner --staged           Scan currently staged (git add'ed) files
  secret-scanner --path src/        Scan a specific file or directory
  secret-scanner --install-hook     Install a git pre-commit hook that runs this scan

Detects: AWS keys, GitHub tokens, Slack tokens, Stripe keys, Google API keys,
private key blocks, JWTs, and generic high-entropy secret assignments.`);
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help || (!args.staged && !args.path && !args.installHook)) {
    printHelp();
    if (!args.help) process.exit(1);
    return;
  }

  if (args.installHook) {
    installHook();
    return;
  }

  const files = args.staged ? stagedFiles() : walk(path.resolve(process.cwd(), args.path));

  if (files.length === 0) {
    console.log('No files to scan.');
    return;
  }

  let totalFindings = [];
  files.forEach((f) => {
    totalFindings = totalFindings.concat(scanFile(f));
  });

  if (totalFindings.length === 0) {
    console.log(`✓ Scanned ${files.length} file(s) — no secrets detected.`);
    process.exit(0);
  }

  console.error(`✗ Found ${totalFindings.length} potential secret(s) in ${files.length} file(s):\n`);
  totalFindings.forEach((f) => {
    console.error(`  ${f.file}:${f.line}  [${f.rule}]`);
    console.error(`    ${f.snippet}`);
  });
  console.error('\nIf any of these are false positives, review and adjust the rules in src/secret-scanner.js.');
  process.exit(1);
}

main();
