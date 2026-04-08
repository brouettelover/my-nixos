{ inputs, self, ... }:

{
  # 1. LE PLAN (Ton module de configuration)
  flake.wrapperModules.network = { pkgs, ... }: {
    # On définit ce que ce module doit produire
    options.network.package = pkgs.lib.mkOption {
      type = pkgs.lib.types.package;
    };

    config.network.package = pkgs.symlinkJoin {
      name = "network-tools";
      paths = [
        pkgs.wireshark
        pkgs.tshark
        pkgs.tcpdump
      ];
    };
  };

  # 2. L'USINE (Construction du paquet pour chaque système)
  perSystem = { pkgs, ... }: {
    packages.network = (pkgs.lib.evalModules {
      modules = [
        self.wrapperModules.network
        { _module.args.pkgs = pkgs; }
      ];
    }).config.network.package;
  };

  # 3. LA LIVRAISON (Installation sur NixOS)
  flake.nixosModules.network = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.network
    ];
  };
}
