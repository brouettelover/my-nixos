{
  # World of Warcraft (Battle.net) via umu-launcher + GE-Proton.
  #
  # Cible matérielle : Ryzen 5 PRO 5650U + Radeon Vega 7 (RADV),
  # 4 Gio de VRAM UMA + 6 Gio de GTT, écran eDP 1920x1080 @ 60 Hz sans VRR.
  # L'iGPU est le goulot d'étranglement : on rend le jeu en 1280x720 et on
  # remonte en 1080p avec le FSR de gamescope -> ~2x moins de pixels à calculer
  # pour une image nette, plutôt que de baisser la résolution de l'écran.
  flake.nixosModules.wow = { config, pkgs, lib, ... }: let

    gamescope = config.programs.gamescope.package;
    protonGE = pkgs.proton-ge-bin.steamcompattool;

    # Résolution de rendu par défaut (surchargeable : WOW_WIDTH / WOW_HEIGHT).
    renderWidth = 1280;
    renderHeight = 720;
    outputWidth = 1920;
    outputHeight = 1080;
    refresh = 60;

    dxvkConf = pkgs.writeText "wow-dxvk.conf" ''
      # Sur un APU la "VRAM" est de la RAM système : garder les ressources
      # dynamiques en mémoire cachée côté CPU évite les lectures en mémoire
      # write-combined, qui sont catastrophiques en mémoire unifiée.
      d3d11.cachedDynamicResources = a

      # Compile les pipelines en arrière-plan -> supprime l'essentiel des
      # micro-freezes la première fois qu'on voit un sort / une zone.
      dxvk.enableGraphicsPipelineLibrary = Auto

      # 6 cœurs / 12 threads : on garde de la marge pour le jeu pendant les
      # compilations de shaders.
      dxvk.numCompilerThreads = 4
    '';

    mangohudConf = pkgs.writeText "wow-mangohud.conf" ''
      fps
      frametime
      frame_timing=1
      cpu_stats
      cpu_temp
      gpu_stats
      gpu_temp
      ram
      vram
      position=top-left
      font_size=20
      background_alpha=0.4
      # Masqué par défaut, bascule avec Maj droite + F12.
      no_display
      toggle_hud=Shift_R+F12
    '';

    # Préambule commun à toutes les commandes : prefix wine dédié, GE-Proton,
    # et surtout des caches de shaders persistants (le gros du stutter de WoW
    # sous Vulkan vient de la recompilation à chaque session).
    prelude = ''
      WOW_HOME="''${WOW_HOME:-$HOME/Games/wow}"
      export WOW_HOME
      export WINEPREFIX="$WOW_HOME/pfx"
      mkdir -p "$WINEPREFIX" "$WOW_HOME/cache/mesa" "$WOW_HOME/cache/dxvk" "$WOW_HOME/cache/vkd3d"

      # umu-launcher : on tourne hors Steam, sans identifiant de boutique.
      export GAMEID="umu-wow"
      export STORE="none"
      export PROTONPATH="${protonGE}"
      export PROTON_VERB="waitforexitandrun"

      # Caches de shaders persistants.
      export MESA_SHADER_CACHE_DIR="$WOW_HOME/cache/mesa"
      export MESA_SHADER_CACHE_MAX_SIZE="12G"
      export DXVK_STATE_CACHE_PATH="$WOW_HOME/cache/dxvk"
      export VKD3D_SHADER_CACHE_PATH="$WOW_HOME/cache/vkd3d"

      # RADV explicitement (évite de tomber sur AMDVLK si jamais il traîne).
      export AMD_VULKAN_ICD="RADV"
      export DXVK_CONFIG_FILE="${dxvkConf}"

      # Pas de raccourcis parasites créés par wine dans le menu.
      export WINEDLLOVERRIDES="winemenubuilder.exe=d"

      # On passe par le Xwayland de gamescope, pas par le backend wayland
      # expérimental de Proton.
      export PROTON_ENABLE_WAYLAND="0"
    '';

    wow-setup = pkgs.writeShellApplication {
      name = "wow-setup";
      runtimeInputs = [ pkgs.umu-launcher pkgs.curl pkgs.coreutils ];
      text = ''
        ${prelude}

        installer="''${1:-}"
        if [ -z "$installer" ]; then
          for candidate in \
            "$WOW_HOME/Battle.net-Setup.exe" \
            "$HOME/Downloads/Battle.net-Setup.exe" \
            "$HOME/Téléchargements/Battle.net-Setup.exe"; do
            if [ -f "$candidate" ]; then
              installer="$candidate"
              break
            fi
          done
        fi

        if [ -z "$installer" ]; then
          installer="$WOW_HOME/Battle.net-Setup.exe"
          echo "Téléchargement de l'installeur Battle.net..."
          curl -fL --progress-bar -o "$installer" \
            "https://downloader.battle.net/download/getInstaller?os=win&installer=Battle.net-Setup.exe"
        fi

        echo "Prefix : $WINEPREFIX"
        echo "Proton : $PROTONPATH"
        echo "Installeur : $installer"
        echo
        echo "Première exécution : umu télécharge le runtime Steam (~600 Mo)."
        exec umu-run "$installer"
      '';
    };

    wow-launcher = pkgs.writeShellApplication {
      name = "wow-launcher";
      runtimeInputs = [ pkgs.umu-launcher pkgs.coreutils ];
      text = ''
        ${prelude}

        bnet="$WINEPREFIX/drive_c/Program Files (x86)/Battle.net/Battle.net Launcher.exe"
        if [ ! -f "$bnet" ]; then
          echo "Battle.net n'est pas installé dans $WINEPREFIX." >&2
          echo "Lance d'abord : wow-setup" >&2
          exit 1
        fi

        cd "$(dirname "$bnet")"
        exec umu-run "$bnet" "$@"
      '';
    };

    # Lancement du jeu lui-même : gamescope (FSR + cap 60 fps aligné sur la
    # dalle) autour de gamemode (gouverneur performance, renice, DPM GPU en
    # "high") autour de umu/Proton.
    wow = pkgs.writeShellApplication {
      name = "wow";
      runtimeInputs = [
        pkgs.umu-launcher
        pkgs.gamemode
        pkgs.mangohud
        pkgs.coreutils
        pkgs.findutils
      ];
      text = ''
        ${prelude}

        export MANGOHUD_CONFIGFILE="${mangohudConf}"

        flavor="''${1:-forever}"
        case "$flavor" in
          forever|_forever_)            flavor="_forever_" ;;
          retail|_retail_)              flavor="_retail_" ;;
          classic|_classic_)            flavor="_classic_" ;;
          era|classic_era|_classic_era_) flavor="_classic_era_" ;;
          ptr|_ptr_)                    flavor="_ptr_" ;;
          *) echo "Version inconnue : $flavor (forever|retail|classic|era|ptr)" >&2; exit 1 ;;
        esac

        exe="$(find "$WINEPREFIX/drive_c" -maxdepth 6 \
          -ipath "*World of Warcraft/$flavor/Wow.exe" -print -quit 2>/dev/null || true)"

        if [ -z "$exe" ]; then
          echo "Wow.exe ($flavor) introuvable dans $WINEPREFIX." >&2
          echo "Installe le jeu via Battle.net : wow-launcher" >&2
          exit 1
        fi

        width="''${WOW_WIDTH:-${toString renderWidth}}"
        height="''${WOW_HEIGHT:-${toString renderHeight}}"

        cd "$(dirname "$exe")"

        if [ -n "''${WOW_NO_GAMESCOPE:-}" ]; then
          exec gamemoderun umu-run "$exe"
        fi

        exec ${lib.getExe gamescope} \
          -W ${toString outputWidth} -H ${toString outputHeight} \
          -w "$width" -h "$height" \
          -r ${toString refresh} \
          -S fit -F fsr --fsr-sharpness 2 \
          --force-grab-cursor \
          --mangoapp \
          -f \
          -- gamemoderun umu-run "$exe"
      '';
    };

    # Réglages graphiques de WoW adaptés à un Vega 7 : écrits directement dans
    # Config.wtf, ce que l'interface du jeu ne permet pas de faire finement.
    wow-tune = pkgs.writeShellApplication {
      name = "wow-tune";
      runtimeInputs = [ pkgs.coreutils pkgs.findutils pkgs.gnused ];
      text = ''
        ${prelude}

        flavor="''${1:-_forever_}"
        wtf="$(find "$WINEPREFIX/drive_c" -maxdepth 7 \
          -ipath "*World of Warcraft/$flavor/WTF/Config.wtf" -print -quit 2>/dev/null || true)"

        if [ -z "$wtf" ]; then
          echo "Config.wtf introuvable : lance le jeu une fois, puis relance wow-tune." >&2
          exit 1
        fi

        cp -f "$wtf" "$wtf.bak"

        set_cvar() {
          if grep -qi "^SET $1 " "$wtf"; then
            sed -i "s|^SET $1 .*|SET $1 \"$2\"|I" "$wtf"
          else
            printf 'SET %s "%s"\n' "$1" "$2" >> "$wtf"
          fi
        }

        # DXVK (D3D11) est plus rapide et plus stable que vkd3d sur Vega.
        set_cvar gxApi D3D11
        set_cvar graphicsQuality 2
        set_cvar RAIDgraphicsQuality 1
        set_cvar gxMaxFrameLatency 2
        # Cap aligné sur la dalle 60 Hz, 30 en arrière-plan (batterie/chauffe).
        set_cvar maxFPS 60
        set_cvar maxFPSBk 30
        set_cvar textureFilteringMode 2
        set_cvar MSAAQuality 0
        set_cvar SSAOLevel 0
        set_cvar volumeFogLevel 0
        set_cvar weatherDensity 0
        set_cvar spellClutter 0
        set_cvar ffxGlow 0

        echo "Config.wtf ajusté ($wtf), sauvegarde : $wtf.bak"
      '';
    };

    wow-winecfg = pkgs.writeShellApplication {
      name = "wow-winecfg";
      runtimeInputs = [ pkgs.umu-launcher pkgs.coreutils ];
      text = ''
        ${prelude}
        exec umu-run winecfg
      '';
    };

    wowDesktop = pkgs.makeDesktopItem {
      name = "wow";
      desktopName = "World of Warcraft";
      comment = "WoW via GE-Proton, gamescope FSR 720p->1080p et GameMode";
      exec = "${lib.getExe wow}";
      icon = "applications-games";
      categories = [ "Game" "RolePlaying" ];
      terminal = false;
    };

    wowLauncherDesktop = pkgs.makeDesktopItem {
      name = "wow-launcher";
      desktopName = "Battle.net (WoW)";
      comment = "Launcher Battle.net du prefix WoW (connexion, mises à jour)";
      exec = "${lib.getExe wow-launcher}";
      icon = "applications-games";
      categories = [ "Game" ];
      terminal = false;
    };

  in {
    unfreePackages = [ "wowup-cf" "proton-ge-bin" "steam-run" ];

    programs.gamescope = {
      enable = true;
      # Couche WSI Vulkan : le jeu présente ses images directement à gamescope
      # au lieu de passer par un blit Xwayland -> frame pacing plus propre et
      # limiteur de fps exact.
      enableWsi = true;
    };

    # GameMode : activé à la volée par gamemoderun, rendu à l'état initial à la
    # fermeture du jeu. Indispensable ici, l'APU est en powersave par défaut.
    programs.gamemode = {
      enable = true;
      settings = {
        general = {
          renice = 10;
          softrealtime = "auto";
          inhibit_screensaver = 1;
        };
        cpu = {
          # Un 5650U est limité par son enveloppe de 15 W : parquer ou épingler
          # des cœurs ne fait que réduire le budget thermique disponible.
          park_cores = "no";
          pin_cores = "no";
        };
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 0;
          # Débride les fréquences de l'iGPU pendant le jeu.
          amd_performance_level = "high";
        };
        custom = {
          start = "${pkgs.libnotify}/bin/notify-send 'GameMode' 'Mode jeu activé'";
          end = "${pkgs.libnotify}/bin/notify-send 'GameMode' 'Mode jeu désactivé'";
        };
      };
    };

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # WoW et wine mappent énormément de petites zones mémoire.
    boot.kernel.sysctl = {
      "vm.max_map_count" = 2147483642;
      # 4 Gio de RAM sont réservés à l'iGPU : il reste ~11 Gio. zram étant la
      # swap prioritaire et compressée en RAM, on la préfère largement au disque.
      "vm.swappiness" = 150;
    };

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    environment.systemPackages = [
      wow
      wow-setup
      wow-launcher
      wow-tune
      wow-winecfg
      wowDesktop
      wowLauncherDesktop

      pkgs.umu-launcher
      pkgs.mangohud
      pkgs.wowup-cf      # gestionnaire d'addons CurseForge
      pkgs.protonup-qt   # pour récupérer d'autres GE-Proton si besoin
      pkgs.lact          # courbes de ventilation / limites de l'iGPU
    ];

    # LACT pour surveiller et limiter l'iGPU (utile en jeu sur batterie).
    services.lact.enable = true;
  };
}
