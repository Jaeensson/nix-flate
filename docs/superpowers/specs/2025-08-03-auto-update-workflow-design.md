# Auto-Update GitHub Workflow — Design Spec

**Date:** 2025-08-03
**Status:** Approved

## Overview

Add a GitHub Actions workflow that automatically checks for new releases of upstream [flate](https://github.com/home-operations/flate), updates `flake.nix` with the new version and hashes, and opens a PR with the changes.

## Trigger

- **Schedule:** Daily at midnight UTC (`cron: '0 0 * * *'`)
- **Manual:** `workflow_dispatch` for on-demand runs

## Permissions

- `contents: write` — push branches, delete branches
- `pull-requests: write` — create and close PRs

## Workflow Steps

1. **Checkout** the repository
2. **Install Nix** using the Determinate Systems `install-nix-action`
3. **Fetch latest release** from `home-operations/flate` via GitHub API (`/repos/home-operations/flate/releases/latest`)
4. **Parse current version** from `flake.nix` (extract the `version` field)
5. **Compare versions** — if identical, exit cleanly (nothing to do)
6. **Prefetch source hash** using `nix store prefetch-file` with the new tarball URL
7. **Compute vendorHash** by running `nix build` with a placeholder vendorHash; extract the correct hash from the error output
8. **Update `flake.nix`** via `sed`:
   - `version` → new version string
   - `rev` → new tag
   - `hash` → new SRI hash
   - `vendorHash` → corrected vendorHash
   - `ldflags` → `-X main.version=<new-version>`
9. **Close existing update PRs** authored by `github-actions[bot]` with branch prefix `auto/flate-`; delete associated branches
10. **Create branch** (`auto/flate-v{version}`), commit, push, and open PR

## PR Details

- **Branch:** `auto/flate-v{version}` (e.g., `auto/flate-v0.4.13`)
- **Title:** `chore: update flate to v{version}`
- **Body:** Link to the upstream release on GitHub
- **Author:** `github-actions[bot]`

## Error Handling

| Scenario | Behavior |
|---|---|
| GitHub API call fails | Exit gracefully, no PR |
| No new version | Exit cleanly with success |
| `nix build` fails unexpectedly (not vendorHash mismatch) | Fail the workflow |
| `nix store prefetch-file` fails | Fail the workflow |
| `gh` CLI operations fail | Fail the workflow |
