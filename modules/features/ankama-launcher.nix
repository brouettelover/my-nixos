{
  flake.nixosModules.ankama-launcher = { pkgs, ... }: let
    ankama = pkgs.ankama-launcher.override {
      appimageTools = pkgs.appimageTools // {
        wrapType2 = args: pkgs.appimageTools.wrapType2 (args // {
          extraPkgs = p: (args.extraPkgs or (_: [ ])) p ++ [
            p.libxrandr
            p.libxinerama
            p.libxext
            p.libx11
          ];
        });
      };
    };
  in {
    unfreePackages = [ "ankama-launcher" ];

    environment.systemPackages = [
      ankama
      pkgs.strace
    ];
  };
}
