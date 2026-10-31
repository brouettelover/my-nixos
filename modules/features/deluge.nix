{
  flake.nixosModules.deluge = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.deluge ];
  };
}
