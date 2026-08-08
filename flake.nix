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
            version = "0.4.14";

            src = pkgs.fetchFromGitHub {
              owner = "home-operations";
              repo = "flate";
              rev = "v0.4.14";
              hash = "sha256-TynTUMgrOc3qLEKaE/CPprPix2GFVW+LpnzlqZJb848=";
            };

            vendorHash = "sha256-0o3pibMkswbV9mtwj2iNEMP0BIB+dqTvDTBQselGWKk=";

            subPackages = [ "cmd/flate" ];

            env = {
              CGO_ENABLED = "0";
            };

            doCheck = false;

            ldflags = [
              "-s"
              "-w"
              "-X main.version=0.4.14"
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
