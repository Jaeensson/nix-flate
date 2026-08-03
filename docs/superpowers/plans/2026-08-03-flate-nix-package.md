# flate Nix Package — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Package flate v0.4.12 as a Nix flake using `buildGoModule`.

**Architecture:** Single `flake.nix` with nixpkgs-unstable input, `buildGoModule` output. Static binary (`CGO_ENABLED = 0`), version stamped via ldflags, tests skipped.

**Tech Stack:** Nix flakes, `buildGoModule`, nixpkgs-unstable (Go 1.26.5)

## Global Constraints

- nixpkgs: `github:NixOS/nixpkgs/nixpkgs-unstable`
- Go version matches flate go.mod: 1.26.5 (available in nixpkgs-unstable)
- Source: `github:home-operations/flate` tag `v0.4.12`
- `CGO_ENABLED = 0` for static binary
- `doCheck = false` — skip tests
- Version ldflags: `-X main.version=<tag>` and `-X main.commit=<rev>`
- License: AGPL-3.0

---

### Task 1: Create flake.nix

**Files:**
- Create: `flake.nix`

**Interfaces:**
- Produces: `packages.<system>.default` and `packages.<system>.flate` — the flate binary

- [ ] **Step 1: Write flake.nix with initial structure**

```nix
{
  description = "flate — A Flux resource validator and inflator";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          default = self.packages.${system}.flate;
          flate = pkgs.buildGoModule {
            pname = "flate";
            version = "0.4.12";

            src = pkgs.fetchFromGitHub {
              owner = "home-operations";
              repo = "flate";
              rev = "v0.4.12";
              hash = ""; # Fill after first build attempt
            };

            vendorHash = ""; # Fill after first build attempt

            subPackages = [ "cmd/flate" ];

            CGO_ENABLED = 0;

            doCheck = false;

            ldflags = [
              "-s"
              "-w"
              "-X main.version=0.4.12"
            ];

            meta = with pkgs.lib; {
              description = "A Flux resource validator and inflator — render and diff Flux GitOps repositories fully offline";
              homepage = "https://github.com/home-operations/flate";
              license = licenses.agpl3Only;
              mainProgram = "flate";
              platforms = platforms.unix;
            };
          };
        };
      });
}
```

- [ ] **Step 2: Attempt first build to get hashes**

Run:
```bash
nix build .#flate 2>&1 | tee /tmp/build-log.txt
```

Expected: FAIL — will report the actual hash for `src` (and possibly `vendorHash`). The error message will say something like:
```
hash mismatch in fixed-output derivation ...
  got:    sha256-...
  wanted: sha256-...
```

- [ ] **Step 3: Fill in the `src` hash**

From the error output, extract the actual hash and update `flake.nix`:
```
hash = "sha256-<actual-hash-from-error>";
```

- [ ] **Step 4: Attempt second build**

Run:
```bash
nix build .#flate 2>&1 | tee /tmp/build-log2.txt
```

Expected: Either success, or a `vendorHash` mismatch error with the actual vendor hash.

- [ ] **Step 5: Fill in `vendorHash` if needed**

If step 4 fails with a vendorHash mismatch, extract the actual hash and update:
```
vendorHash = "sha256-<actual-vendor-hash>";
```

- [ ] **Step 6: Verify build succeeds**

Run:
```bash
nix build .#flate
```

Expected: Success — resulting binary at `./result/bin/flate`.

- [ ] **Step 7: Verify binary works**

Run:
```bash
./result/bin/flate --version
```

Expected: Outputs `0.4.12` (not `dev`).

- [ ] **Step 8: Commit**

```bash
git add flake.nix flake.lock
git commit -m "feat: add flate v0.4.12 nix package"
```
