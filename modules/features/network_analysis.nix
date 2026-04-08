{ inputs, self, ... }:

{
  # 1. LE PLAN (Ton module de configuration)
  flake.wrapperModules.network_analysis = { pkgs, ... }: {
    # On définit ce que ce module doit produire
    options.network_analysis.package = pkgs.lib.mkOption {
      type = pkgs.lib.types.package;
    };

    config.network_analysis.package = pkgs.symlinkJoin {
      name = "network_analysis-tools";
      paths = [
        pkgs.wireshark
        pkgs.tshark
        pkgs.tcpdump
      ];
    };
  };

  # 2. L'USINE (Construction du paquet pour chaque système)
  perSystem = { pkgs, ... }: {
    packages.network_analysis = (pkgs.lib.evalModules {
      modules = [
        self.wrapperModules.network_analysis
        { _module.args.pkgs = pkgs; }
      ];
    }).config.network_analysis.package;
  };

  # 3. LA LIVRAISON (Installation sur NixOS)
  flake.nixosModules.network_analysis = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.network_analysis
    ];
  };
}
