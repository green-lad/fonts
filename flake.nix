{
  description = "A flake giving access to fonts that I use, outside of nixpkgs.";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  # some font websites:
  # https://www.1001fonts.com
  # https://www.dfonts.org
  # https://www.fontspace.com/
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        # to get sha256 use: nix-prefetch-url --unpack <zip_url>
        fonts = [
          {
            name = "astetica";
            url = "https://www.1001fonts.com/download/astetica.zip";
            sha256 = "0vmb00sbdrgkjkf8kzl3gi0vyj9vjm5ar719w8qjxxi4wsihnzbs";
          }
          {
            name = "leafery";
            url = "https://get.fontspace.co/download/family/7nexw/a056bf699c9d45f8b8bcd2bccd7f4137/leafery-font.zip";
            sha256 = "0fjhwhjii1vv4dgvw57xgvb7p5j1qnhzjs18dy10mj1mjqld8fj2";
          }
        ];
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        defaultPackage = pkgs.symlinkJoin {
          name = "myfonts-0.1.2";
          paths = builtins.attrValues self.packages.${system};
        };

        packages = builtins.listToAttrs (builtins.map (
          v: {
            name = "${v.name}";
            value = pkgs.stdenvNoCC.mkDerivation {
              name = "${v.name}-font";
              dontConfigue = true;
              src = pkgs.fetchzip {
                url = "${v.url}";
                sha256 = "${v.sha256}";
                stripRoot = false;
              };
              installPhase = ''
                mkdir -p $out/share/fonts/truetype
                echo $src
                if stat -t $src/*.otf >/dev/null 2>&1; then
                  cp $src/*.otf $out/share/fonts/truetype/
                fi

                if stat -t $src/*.ttf >/dev/null 2>&1; then
                # if compgen -G $src/*.ttf > /dev/null; then
                  cp $src/*.ttf $out/share/fonts/truetype/
                fi
              '';
              meta = {
                description = "Derivation for the ${v.name} font.";
              };
            };
          }
        ) fonts );
      }
    );
}
