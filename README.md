# Secret Scanner

![CI](https://img.shields.io/github/actions/workflow/status/OWNER/secret-scanner/ci.yml?branch=main&label=build)
![Release](https://img.shields.io/github/v/release/OWNER/secret-scanner?label=release)
![License](https://img.shields.io/github/license/OWNER/secret-scanner)
![Node](https://img.shields.io/badge/node-%3E%3D18-brightgreen)

> A pre-commit tool that scans staged files for API keys, tokens, and credentials before they leak.

## Install

```bash
git clone https://github.com/OWNER/secret-scanner.git
cd secret-scanner
bash scripts/setup.sh
```

## Usage

```bash
npm start -- --staged
```

```bash
npm start -- --install-hook
```

Run `npm start -- --help` for the full CLI reference.

## npm scripts

| Script | What it does |
|---|---|
| `npm start` | Runs the core CLI (`src/secret-scanner.js`) |
| `npm test` | Runs the test suite |
| `npm run tracker` | Shows achievement badge progress |
| `npm run roadmap` | Shows the Day 1 → Month 1 roadmap |
| `npm run setup` | Checks dependencies, makes scripts executable |

## Automation scripts (`scripts/`)

| Script | What it does |
|---|---|
| `setup.sh` | Checks Node/gh dependencies, installs npm packages, chmods scripts |
| `quickdraw.sh` | Opens and closes a GitHub issue in under 5 minutes |
| `yolo.sh` | Creates a branch, opens a PR, merges it without review |
| `publicist.sh` | Creates a `v1.0.0` GitHub Release |
| `pull-shark.sh <count>` | Merges `<count>` PRs — `2`=Bronze, `16`=Silver, `128`=Gold |
| `pair-extraordinaire.sh "Name" "email"` | Creates a co-authored, merged PR |
| `unlock-all.sh` | Interactive menu for all of the above, plus a "Full Blast" run-everything option |

All scripts check `gh auth status` first and print a fix if you're not authenticated, auto-detect the current repo via `gh repo view`, and use timestamps so branch/tag names never collide.

## Codespaces

This repo ships a `.devcontainer/devcontainer.json` that installs Node 20 and the GitHub CLI automatically — just click **Code → Codespaces → Create codespace**.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE)
