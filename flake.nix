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
            version = "0.5.1";

            src = pkgs.fetchFromGitHub {
              owner = "home-operations";
              repo = "flate";
              rev = "v0.5.1";
              hash = "sha256-kwuY7ZDFFNsPsdjvX0jthwsDB3svSb/Sz0eIw4m9X0k=";
            };

            vendorHash = "sha256-REVrrpO7Wbd3jj+2x1eLODLiXfpLvnYkS1o5wp3mGm0=";

            subPackages = [ "cmd/flate" ];

            env = {
              CGO_ENABLED = "0";
            };

            doCheck = false;

            ldflags = [
              "-s"
              "-w"
              "-X main.version=0.5.1"
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
