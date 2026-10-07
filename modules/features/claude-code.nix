{
  flake.nixosModules.claude-code = { pkgs, lib, ... }: {
    unfreePackages = [ "claude-code" ];
    environment.systemPackages = [ pkgs.claude-code ];
  };
}
