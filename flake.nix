{
  description = "hugo-creative-portfolio-theme";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        exampleSite = pkgs.stdenv.mkDerivation {
          pname = "hugo-creative-portfolio-theme-example";
          version = "0.1.0";
          src = ./.;
          buildPhase = ''
            runHook preBuild
            mkdir -p exampleSite/themes
            ln -sfn "$PWD" exampleSite/themes/hugo-creative-portfolio-theme
            ${pkgs.hugo}/bin/hugo --source exampleSite --theme hugo-creative-portfolio-theme --minify
            runHook postBuild
          '';
          installPhase = ''
            runHook preInstall
            cp -r exampleSite/public $out
            runHook postInstall
          '';
        };
      in {
        packages = {
          default = exampleSite;
          exampleSite = exampleSite;
        };

        apps = {
          hugo = {
            type = "app";
            program = toString (pkgs.writeShellScript "hugo" ''
              set -eu
              exec ${pkgs.hugo}/bin/hugo "$@"
            '');
          };
          default = self.apps.${system}.hugo;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [ hugo ];
        };
      });
}
