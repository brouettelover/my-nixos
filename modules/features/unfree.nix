{
  flake.nixosModules.unfree = { config, lib, ... }: {
    options.unfreePackages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Noms des paquets non libres autorisés";
    };

    config.nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) config.unfreePackages;
  };
}
