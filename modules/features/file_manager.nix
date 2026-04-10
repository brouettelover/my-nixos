{ inputs, self, ... }:

{
  # 1. LE PLAN (Ton module de configuration)
  flake.wrapperModules.file_manager = { pkgs, ... }: {
    # On définit ce que ce module doit produire
    options.file_manager.package = pkgs.lib.mkOption {
      type = pkgs.lib.types.package;
    };

    config.file_manager.package = pkgs.symlinkJoin {
      name = "file_manager-tools";
      paths = [
        pkgs.xfce.thunar
        pkgs.xfce.thunar-archive-plugin
        pkgs.xfce.thunar-dropbox-plugin
        pkgs.xfce.thunar-media-tags-plugin
        pkgs.xfce.thunar-vcs-plugin
        pkgs.xfce.thunar-volman
      ];
    };
  };

  # 2. L'USINE (Construction du paquet pour chaque système)
  perSystem = { pkgs, ... }: {
    packages.file_manager = (pkgs.lib.evalModules {
      modules = [
        self.wrapperModules.file_manager
        { _module.args.pkgs = pkgs; }
      ];
    }).config.file_manager.package;
  };

  # 3. LA LIVRAISON (Installation sur NixOS)
  flake.nixosModules.file_manager = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.file_manager
    ];
  };
}
