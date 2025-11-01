{
  description = "Ambxst by Axenide";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixgl,
  }: let
    linuxSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "i686-linux"
    ];

    forAllSystems = f:
      builtins.foldl' (acc: system: acc // {${system} = f system;}) {} linuxSystems;
  in {
    packages = forAllSystems (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        nixGL = nixgl.packages.${system}.nixGLDefault;

        wrapWithNixGL = pkg:
          pkgs.symlinkJoin {
            name = "${pkg.pname or pkg.name}-nixGL";
            paths = [pkg];
            buildInputs = [pkgs.makeWrapper];
            postBuild = ''
              for bin in $out/bin/*; do
                if [ -x "$bin" ]; then
                  mv "$bin" "$bin.orig"
                  makeWrapper ${nixGL}/bin/nixGL "$bin" --add-flags "$bin.orig"
                fi
              done
            '';
          };

        env = pkgs.buildEnv {
          name = "ambxst-env";
          paths = with pkgs; [
            # Env core
            (wrapWithNixGL quickshell)
            (wrapWithNixGL gpu-screen-recorder)
            (wrapWithNixGL mpvpaper)

            # Brightness utils
            brightnessctl
            ddcutil

            # Wayland / basics
            wl-clipboard
            cliphist
            nixGL
            mesa
            libglvnd
            egl-wayland
            wayland

            # Qt
            qt6.qtbase
            qt6.qtsvg
            qt6.qttools
            qt6.qtwayland
            qt6.qtdeclarative
            qt6.qtimageformats
            qt6.qtwebengine

            # UI / tools
            kdePackages.breeze-icons
            hicolor-icon-theme
            fuzzel
            wtype
            imagemagick
            matugen
            ffmpeg

            # MPRIS / DBus / Portals
            playerctl
            xdg-desktop-portal
            xdg-desktop-portal-hyprland

            # PipeWire stack
            pipewire
            wireplumber
          ];
        };

        launcher = pkgs.writeShellScriptBin "ambxst" ''
          set -e
          cd ${self}
          exec ${nixGL}/bin/nixGL ${pkgs.quickshell}/bin/qs -p ${self}/shell.qml
        '';

        ambxst = pkgs.buildEnv {
          name = "ambxst";
          paths = [env launcher];
        };
      in {
        default = ambxst;
        ambxst = ambxst;
      }
    );
  };
}
