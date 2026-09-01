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
          flate = pkgs.buildGo127Module {
            pname = "flate";
            version = "0.6.2";

            src = pkgs.fetchFromGitHub {
              owner = "home-operations";
              repo = "flate";
              rev = "v0.6.2";
              hash = "sha256-omjnwWCSoj/OU7O4vGwK4qkCoPT+kv/IP8s99AQ3eQs=";
            };

            vendorHash = "sha256-pKO/oahZDvk3HVOSSFv/Qw0inRMUx35W6VTOYeEnD3Q=";

            subPackages = [ "cmd/flate" ];

            env = {
              CGO_ENABLED = "0";
            };

            doCheck = false;

            ldflags = [
              "-s"
              "-w"
              "-X main.version=0.6.2"
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
