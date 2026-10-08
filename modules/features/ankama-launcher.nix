{
  flake.nixosModules.ankama-launcher = { pkgs, ... }: let
    ankama = pkgs.ankama-launcher.override {
      appimageTools = pkgs.appimageTools // {
        wrapType2 = args: pkgs.appimageTools.wrapType2 (args // {
          extraPkgs = p: (args.extraPkgs or (_: [ ])) p ++ (with p; [
            # .NET / Unity (cause n°1 de cette erreur)
            icu
            openssl
            krb5
            zlib
            libuuid

            # X11 / entrées
            libx11
            libxext
            libxrandr
            libxinerama
            libxcursor
            libxi
            libxrender
            libxscrnsaver
            libxcb
            libxkbcommon

            # Rendu
            libGL
            libdrm
            mesa
            vulkan-loader
            fontconfig
            freetype

            # Son
            libpulseaudio
            alsa-lib
          ]);

          # Repli si ICU n'est toujours pas trouvé : décommente
          # profile = (args.profile or "") + ''
          #   export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
          # '';
        });
      };
    };
  in {
    unfreePackages = [ "ankama-launcher" ];

    environment.systemPackages = [
      ankama
      pkgs.gamescope
      (pkgs.writeShellScriptBin "dofus" ''
      exec ${pkgs.gamescope}/bin/gamescope -W 1920 -H 1080 -f -- ${ankama}/bin/ankama-launcher "$@"
      '')
    ];

    hardware.graphics.enable = true;
  };
}
