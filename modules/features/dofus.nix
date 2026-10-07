{
  flake.nixosModules.dofus = { pkgs, ... }: let
    dofus = pkgs.writeShellApplication {
      name = "dofus";
      runtimeInputs = [ pkgs.wineWow64Packages.stable pkgs.curl pkgs.findutils ];
      text = ''
        export WINEPREFIX="$HOME/.local/share/dofus-wine"

        find_launcher() {
          find "$WINEPREFIX/drive_c" -iname "Ankama Launcher.exe" -print -quit 2>/dev/null || true
        }

        launcher="$(find_launcher)"

        if [ -z "$launcher" ]; then
          echo "Premier lancement : installation du launcher Ankama (Windows)…"
          mkdir -p "$WINEPREFIX"
          installer="$WINEPREFIX/ankama-setup.exe"
          if [ ! -f "$installer" ]; then
            curl -fL -o "$installer" \
              "https://launcher.cdn.ankama.com/installers/production/Ankama%20Launcher-Setup.exe"
          fi
          wine "$installer"
          launcher="$(find_launcher)"
        fi

        if [ -z "$launcher" ]; then
          echo "Launcher introuvable après installation." >&2
          exit 1
        fi

        exec wine "$launcher" "$@"
      '';
    };

    dofusUrlHandler = pkgs.makeDesktopItem {
      name = "dofus-zaap";
      desktopName = "Ankama Launcher (Wine)";
      exec = "dofus %u";
      mimeTypes = [ "x-scheme-handler/zaap" ];
      noDisplay = true;
    };
  in {
    environment.systemPackages = [
      dofus
      dofusUrlHandler
    ];

    xdg.mime.defaultApplications."x-scheme-handler/zaap" = "dofus-zaap.desktop";
  };
}
