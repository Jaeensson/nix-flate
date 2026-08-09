{
  description = "flate — A Flux resource validator and inflator";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = self.packages.${system}.flate;
          flate = pkgs.buildGoModule {
            pname = "flate";
            version = "0.5.0";

            src = pkgs.fetchFromGitHub {
              owner = "home-operations";
              repo = "flate";
              rev = "v0.5.0";
              hash = "sha256-1ETtB1vsgs+xsKBK8hbUB+dzK9t+khqo0q3XPKVIMbE=";
            };

            vendorHash = "sha256-5/vEIBU0vkeIMw9ghmaR+f0hYwSDQt0I3kGJUoaEIng=";

            subPackages = [ "cmd/flate" ];

            env = {
              CGO_ENABLED = "0";
            };

            doCheck = false;

            ldflags = [
              "-s"
              "-w"
              "-X main.version=0.5.0"
            ];

            meta = with pkgs.lib; {
              description = "A Flux resource validator and inflator — render and diff Flux GitOps repositories fully offline";
              homepage = "https://github.com/home-operations/flate";
              license = licenses.agpl3Only;
              mainProgram = "flate";
              platforms = platforms.unix;
            };
          };
        });
    };
}
