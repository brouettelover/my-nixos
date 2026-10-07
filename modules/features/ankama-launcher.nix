{
  flake.nixosModules.ankama-launcher = { pkgs, ... }: {
    unfreePackages = [ "ankama-launcher" ];

    programs.gamescope.enable = true;

    environment.systemPackages = [
      pkgs.ankama-launcher
      (pkgs.writeShellScriptBin "dofus" ''
        exec gamescope -W 1920 -H 1080 -f -- ankama-launcher --no-sandbox "$@"
      '')
    ];
  };
}
