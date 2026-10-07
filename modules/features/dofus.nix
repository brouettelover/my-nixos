{
  flake.nixosModules.dofus = { pkgs, ... }: {
    environment.systemPackages = [
      (pkgs.writeShellApplication {
        name = "dofus";
        runtimeInputs = [ pkgs.umu-launcher pkgs.curl pkgs.findutils ];
        text = ''
          export WINEPREFIX="$HOME/.local/share/dofus-proton"
          export GAMEID="umu-dofus"
          export PROTONPATH="GE-Proton"

          find_launcher() {
            find "$WINEPREFIX/drive_c" -iname "Ankama Launcher.exe" -print -quit 2>/dev/null || true
          }

          launcher="$(find_launcher)"

          if [ -z "$launcher" ]; then
            echo "Premier lancement : installation du launcher Ankama (Windows)…"
            mkdir -p "$WINEPREFIX"
            installer="$WINEPREFIX/ankama-setup.exe"
            curl -fL -o "$installer" \
              "https://launcher.cdn.ankama.com/installers/production/Ankama%20Launcher-Setup.exe"
            umu-run "$installer"
            launcher="$(find_launcher)"
          fi

          if [ -z "$launcher" ]; then
            echo "Launcher introuvable après installation." >&2
            exit 1
          fi

          exec umu-run "$launcher"
        '';
      })
    ];
  };
}
