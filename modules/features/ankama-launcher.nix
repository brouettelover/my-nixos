{
  flake.nixosModules.ankama-launcher = { config, pkgs, lib, ... }: let
    ankama = pkgs.ankama-launcher.override {
      appimageTools = pkgs.appimageTools // {
        wrapType2 = args: pkgs.appimageTools.wrapType2 (args // {
          extraPkgs = p: (args.extraPkgs or (_: [ ])) p ++ (with p; [
            # .NET / Unity
            icu
            openssl
            zlib
            stdenv.cc.cc.lib # libstdc++.so.6 - requis par libScreenManagerNativeProxy.so (et d'autres plugins natifs Unity)

            # X11
            libx11
            libxext
            libxrandr
            libxinerama
            libxcursor
            libxi
            libxrender
            libxkbcommon

            # Wayland (fallback utilisé par libScreenManagerNativeProxy.so si le chemin X11 échoue)
            wayland

            # Rendu / son
            libGL
            vulkan-loader
            libpulseaudio
          ]);
        });
      };
    };

    gamescope = config.programs.gamescope.package;

    dofus = pkgs.writeShellScriptBin "dofus" ''
      exec ${lib.getExe gamescope} \
        -W 1920 -H 1080 \
        -w 1920 -h 1080 \
        -f \
        -- ${lib.getExe ankama} "$@"
    '';

    dofusDesktop = pkgs.makeDesktopItem {
      name = "dofus";
      desktopName = "Dofus";
      comment = "Ankama Launcher via gamescope";
      exec = "${lib.getExe dofus}";
      icon = "ankama-launcher";
      categories = [ "Game" ];
    };
  in {
    unfreePackages = [ "ankama-launcher" ];

    programs.gamescope.enable = true;
    hardware.graphics.enable = true;

    environment.systemPackages = [
      ankama
      dofus
      dofusDesktop
    ];
  };
}
