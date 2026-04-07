{ inputs, self, ... }:

{
  # 1. LE PLAN (Ton module de configuration)
  flake.wrapperModules.firefox = { pkgs, ... }: {
    # On définit ce que ce module doit produire
    options.firefox.package = pkgs.lib.mkOption {
      type = pkgs.lib.types.package;
    };

    config.firefox.package = pkgs.symlinkJoin {
      name = "firefox-tools";
      paths = [
        pkgs.firefox
      ];
    };
  };

  # 2. L'USINE (Construction du paquet pour chaque système)
  perSystem = { pkgs, ... }: {
    packages.firefox = (pkgs.lib.evalModules {
      modules = [
        self.wrapperModules.firefox
        { _module.args.pkgs = pkgs; }
      ];
    }).config.firefox.package;
  };

  # 3. LA LIVRAISON (Installation sur NixOS)
  flake.nixosModules.firefox = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.firefox
    ];
  };
}
