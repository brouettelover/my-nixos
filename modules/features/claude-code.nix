{
  flake.nixosModules.claude-code = { pkgs, lib, ... }: {
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [ "claude-code" ];

    environment.systemPackages = [ pkgs.claude-code ];
  };
}
