{
  flake.nixosModules.discord = { pkgs, ... }: {
    unfreePackages = [ "discord" ];
    environment.systemPackages = [ pkgs.discord ];
  };
}
