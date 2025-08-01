{
  description =
    "A flake giving access to fonts that I use, outside of nixpkgs.";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  # some font websites:
  # https://www.1001fonts.com
  # https://www.dfonts.org
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        defaultPackage = pkgs.symlinkJoin {
          name = "myfonts-0.1.0";
          paths = builtins.attrValues
            self.packages.${system}; # Add font derivation names here
        };

        packages.astetica = pkgs.stdenvNoCC.mkDerivation {
          name = "astetica-font";
          dontConfigue = true;
          src = pkgs.fetchzip {
            url =
              "https://www.1001fonts.com/download/astetica.zip";
            sha256 = "0vmb00sbdrgkjkf8kzl3gi0vyj9vjm5ar719w8qjxxi4wsihnzbs";
            # sha256 = "sha256-0vmb00sbdrgkjkf8kzl3gi0vyj9vjm5ar719w8qjxxi4wsihnzbs";
            stripRoot = false;
          };
          installPhase = ''
            mkdir -p $out/share/fonts/truetype
            cp $src/*.otf $out/share/fonts/truetype/
            cp $src/*.ttf $out/share/fonts/truetype/
          '';
          meta = { description = "Derivation for the Astetica font."; };
        };
      });
}
