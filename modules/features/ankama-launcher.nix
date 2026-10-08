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

            # X11
            libx11
            libxext
            libxrandr
            libxinerama
            libxcursor
            libxi
            libxrender
            libxkbcommon

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
