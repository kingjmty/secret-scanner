# Contributing to Secret Scanner

Thanks for taking the time to contribute. This project keeps a low-friction workflow so small fixes and big features can both land quickly.

## Getting started

1. Fork the repo and clone your fork.
2. Run `bash scripts/setup.sh` to install dependencies and make helper scripts executable.
3. Create a branch: `git checkout -b feat/short-description`.
4. Make your change, add or update tests where relevant.
5. Run `npm test` before opening a PR.

## Commit style

This project follows [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(scope): add new capability
fix(scope): correct a bug
docs(scope): update documentation
chore(scope): tooling/maintenance
```

## Pull requests

- Keep PRs focused on a single change where possible.
- Fill out the PR template — it's short by design.
- CI must pass (`.github/workflows/ci.yml`) before merge.
- Larger PRs will be labeled automatically by size (see `pr-size-labeler` if this isn't that repo, or this repo's own CI otherwise).

## Reporting issues

Use the Bug Report or Feature Request templates under **Issues > New Issue**. Include reproduction steps, expected vs actual behavior, and your environment (OS, Node version).

## Code of conduct

Be respectful, be constructive, assume good intent. Disagreements about implementation are fine; personal attacks are not.
