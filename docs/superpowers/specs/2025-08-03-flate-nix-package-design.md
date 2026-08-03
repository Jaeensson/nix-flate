# Design: Nix Flake for flate

**Date:** 2025-08-03
**Status:** approved

## Overview

Package [flate](https://github.com/home-operations/flate) — a Flux resource validator and inflator — as a Nix flake. flate is a single Go static binary (AGPL-3.0).

## Structure

```
nix-flate/
├── flake.nix          # Flake entry point
├── flake.lock         # Pinned inputs (committed)
└── README.md          # Basic usage
```

## Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Format | Flake | Modern, reproducible, composable |
| nixpkgs | `nixpkgs-unstable` | Best chance of building with Go 1.26.5 requirement |
| Builder | `buildGoModule` | Standard Go builder in nixpkgs |
| Version | Track tagged releases | Predictable, stable |
| Tests | Skipped (`doCheck = false`) | Avoid network deps, faster builds |
| CGO | `CGO_ENABLED = 0` | Match upstream "one static binary" promise |
| Platforms | Default (`buildGoModule` platforms) | linux/darwin x86_64/aarch64 |

## flake.nix outline

- **inputs:** `nixpkgs` (unstable), `flate-src` (GitHub release tarball)
- **outputs:** `packages.<system>.default` = `flate`
- **build:** `buildGoModule` with `subPackages = ["cmd/flate"]`, `doCheck = false`, `CGO_ENABLED = 0`
- **vendorHash:** Empty initially, filled after first build attempt
- **ldflags:** Set version string from the source tag if the source supports it

## Usage

```bash
nix build .#flate
nix run .#flate -- --help
```
