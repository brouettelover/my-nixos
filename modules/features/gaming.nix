{ inputs, self, ... }:

{
  # 1. LE PLAN (Ton module de configuration)
  flake.wrapperModules.gaming = { pkgs, ... }: {
    # On définit ce que ce module doit produire
    options.gaming.package = pkgs.lib.mkOption {
      type = pkgs.lib.types.package;
    };

    config.gaming.package = pkgs.symlinkJoin {
      name = "gaming-tools";
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        #dedicatedServer.openFirewall = true;
      };
      
      paths = [
        pkgs.lutris
        pkgs.wineWowPackages.stable
        pkgs.winetricks
        pkgs.mangohud
      ];

      zramSwap.enable = true;
    };
  };

  # 2. L'USINE (Construction du paquet pour chaque système)
  perSystem = { pkgs, ... }: {
    packages.gaming = (pkgs.lib.evalModules {
      modules = [
        self.wrapperModules.gaming
        { _module.args.pkgs = pkgs; }
      ];
    }).config.gaming.package;
  };

  # 3. LA LIVRAISON (Installation sur NixOS)
  flake.nixosModules.gaming = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.gaming
    ];
  };
}
