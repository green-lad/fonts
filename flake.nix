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
            # sha256 = "0vmb00sbdrgkjkf8kzl3gi0vyj9vjm5ar719w8qjxxi4wsihnzbs";
            sha256 = "sha256-MP3OQxJ6hgQ3rvMvqYzw7SpXXT326sTBU2D3NAiJhS8=";
          }
          {
            name = "audley-ipswitch";
            url = "https://get.fontspace.co/download/family/p074d/13047c406db34524b8040295a98c26eb/audley-ipswitch-font.zip";
            # sha256 = "1y2f3fdzl5qn6j2227dkm7vj13if1cyh1x09v4wa6xqpwchigz81";
            sha256 = "11r4zy9gnin5bx0rvlqlipxpky86q3lc547zm24vs8qckcf0dl7j";
          }
          {
            name = "leafery";
            url = "https://get.fontspace.co/download/family/7nexw/a056bf699c9d45f8b8bcd2bccd7f4137/leafery-font.zip";
            # sha256 = "0fjhwhjii1vv4dgvw57xgvb7p5j1qnhzjs18dy10mj1mjqld8fj2";
            sha256 = "sha256-QFjcDRbAgulrEv3s12/PCPvJFR4ZXXXc4TBijSSyeCk=";
          }
          {
            name = "lovely-home";
            url = "https://get.fontspace.co/download/family/33ele/90e10d76e8b8432eabb397ed5f3c1914/lovely-home-font.zip";
            # sha256 = "0f64r5n7j2nv7kv43wapmc9ibpjlpnmxxa3fmjflgfzfmypa3nnp";
            sha256 = "sha256-7x1GKkaESFLBaC5RxBtERWyXwafKwSpQ60oV/9fNJvI=";
          }
        ];
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        defaultPackage = pkgs.symlinkJoin {
          name = "myfonts-0.1.4";
          paths = builtins.attrValues self.packages.${system};
        };

        packages = builtins.listToAttrs (
          builtins.map (v: {
            name = "${v.name}";
            value = pkgs.stdenvNoCC.mkDerivation {
              name = "${v.name}-font";
              dontConfigue = true;
              # TODO: fix fetchzip in nixpkgs for zips containing files with no access rights
              # src = pkgs.fetchzip {
              #   url = "${v.url}";
              #   sha256 = "${v.sha256}";
              #   stripRoot = false;
              # };
              # installPhase = ''
              #   mkdir -p $out/share/fonts/truetype
              #   echo $src
              #   if stat -t $src/*.otf >/dev/null 2>&1; then
              #     cp $src/*.otf $out/share/fonts/truetype/
              #   fi

              #   if stat -t $src/*.ttf >/dev/null 2>&1; then
              #     cp $src/*.ttf $out/share/fonts/truetype/
              #   fi
              # '';

              # workaround:
              src = pkgs.fetchurl {
                url = "${v.url}";
                sha256 = "${v.sha256}";
              };
              unpackPhase = ''
                mkdir -p work
                ${pkgs.unzip}/bin/unzip "$src" -d work
                chmod -R a+rX work
              '';
              installPhase = ''
                mkdir -p $out/share/fonts/truetype
                copied=0 
                if stat -t work/*.otf >/dev/null 2>&1; then
                  cp work/*.otf $out/share/fonts/truetype/
                  copied=$((copied + 1))
                fi
                if stat -t work/*.ttf >/dev/null 2>&1; then
                  cp work/*.ttf $out/share/fonts/truetype/
                  # NOTE: fun with bash:
                  #         using "((copied++))" instead leads to sth like "exit 1" without "set -e"
                  copied=$((copied + 1))
                fi
                if [ $copied -eq 0 ]; then
                  echo "package does not contain a known font format"
                  exit 1
                fi
              '';

              meta = {
                description = "Derivation for the ${v.name} font.";
              };
            };
          }) fonts
        );
      }
    );
}
