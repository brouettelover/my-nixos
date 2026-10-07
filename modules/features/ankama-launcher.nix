{
  flake.nixosModules.ankama-launcher = { pkgs, ... }: {
    unfreePackages = [ "ankama-launcher" ];
    environment.systemPackages = [ pkgs.ankama-launcher ];
  };
}
