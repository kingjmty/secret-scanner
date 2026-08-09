#!/usr/bin/env node
/**
 * src/achievement-tracker.js
 * Shows badge progress for Secret Scanner and a Day 1 -> Month 1 roadmap.
 * Usage:
 *   node src/achievement-tracker.js
 *   node src/achievement-tracker.js --roadmap
 */
'use strict';

const { execSync } = require('child_process');

function sh(cmd) {
  try {
    return execSync(cmd, { stdio: ['pipe', 'pipe', 'pipe'] }).toString().trim();
  } catch (e) {
    return null;
  }
}

function ghAuthed() {
  return sh('gh auth status') !== null;
}

function currentRepo() {
  return sh('gh repo view --json nameWithOwner -q .nameWithOwner');
}

const BADGES = [
  { key: 'quickdraw', label: 'Quickdraw', desc: 'Close an issue within 5 minutes of opening it.' },
  { key: 'yolo', label: 'Yolo', desc: 'Merge a PR without review.' },
  { key: 'publicist', label: 'Publicist', desc: 'Publish a release for the repository.' },
  { key: 'pull-shark-bronze', label: 'Pull Shark (Bronze)', desc: 'Merge 2 pull requests.' },
  { key: 'pull-shark-silver', label: 'Pull Shark (Silver)', desc: 'Merge 16 pull requests.' },
  { key: 'pull-shark-gold', label: 'Pull Shark (Gold)', desc: 'Merge 128 pull requests.' },
  { key: 'pair-extraordinaire', label: 'Pair Extraordinaire', desc: 'Co-author a merged commit.' },
];

function printBadgeTable() {
  console.log('=== Secret Scanner — Achievement Badge Progress ===\n');
  const repo = currentRepo();
  if (!ghAuthed()) {
    console.log('⚠ gh is not authenticated — run `gh auth login` to check live status.\n');
  } else if (!repo) {
    console.log('⚠ Could not detect current repo — run this from inside a cloned repo.\n');
  } else {
    console.log(`Repo: ${repo}\n`);
  }

  BADGES.forEach((b) => {
    console.log(`[ ] ${b.label.padEnd(24)} — ${b.desc}`);
  });

  console.log('\nTip: run the matching script in scripts/ to unlock each one,');
  console.log('or run `bash scripts/unlock-all.sh` for the interactive menu.');
  if (repo) {
    const owner = repo.split('/')[0];
    console.log(`\nProfile check: https://github.com/${owner}`);
  }
}

function printRoadmap() {
  console.log('=== Secret Scanner — Day 1 -> Month 1 Roadmap ===\n');
  const roadmap = [
    ['Day 1', 'Run scripts/setup.sh, verify gh auth, run scripts/quickdraw.sh.'],
    ['Day 2-3', 'Run scripts/yolo.sh once to validate branch/PR/merge flow.'],
    ['Week 1', 'Run scripts/pull-shark.sh 2 (Bronze tier).'],
    ['Week 2', 'Run scripts/pair-extraordinaire.sh with a collaborator.'],
    ['Week 3', 'Run scripts/publicist.sh to cut the v1.0.0 release.'],
    ['Week 4', 'Work toward scripts/pull-shark.sh 16 (Silver tier).'],
    ['Month 1', 'Sustain contributions toward scripts/pull-shark.sh 128 (Gold tier).'],
  ];
  roadmap.forEach(([when, what]) => {
    console.log(`${when.padEnd(10)} -> ${what}`);
  });
}

function main() {
  const args = process.argv.slice(2);
  if (args.includes('--roadmap')) {
    printRoadmap();
  } else {
    printBadgeTable();
  }
}

main();
