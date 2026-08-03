# nix-flate

Nix flake for [flate](https://github.com/home-operations/flate) — a Flux resource validator and inflator.

## Usage

### Run directly

```bash
nix run github:Jaeensson/nix-flate -- --help
```

### Build locally

```bash
nix build github:Jaeensson/nix-flate
./result/bin/flate --version
```

### Use as a flake input

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-flate.url = "github:Jaeensson/nix-flate";
  };

  outputs = { nixpkgs, nix-flate, ... }: {
    # Add to system packages
    environment.systemPackages = [
      nix-flate.packages.x86_64-linux.default
    ];

    # Or in a dev shell
    devShells.x86_64-linux.default = pkgs.mkShell {
      buildInputs = [
        nix-flate.packages.x86_64-linux.default
      ];
    };
  };
}
```

### Available platforms

- `x86_64-linux`
- `aarch64-linux`
- `x86_64-darwin`
- `aarch64-darwin`
