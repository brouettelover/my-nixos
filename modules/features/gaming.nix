{ inputs, self, nixpkgs, ... }:

{
  # 1. LE PLAN (Ton module de configuration)
  flake.wrapperModules.gaming = { pkgs, ... }: {
    # On définit ce que ce module doit produire
    options.gaming.package = pkgs.lib.mkOption {
      type = pkgs.lib.types.package;
    };

    config.gaming.package = pkgs.symlinkJoin {
      name = "gaming-tools";
            
      paths = [
        pkgs.lutris
        pkgs.wineWowPackages.stable
        pkgs.winetricks
        pkgs.mangohud
      ];

    };
  };

  # 2. L'USINE (Construction du paquet pour chaque système)
  perSystem = { pkgs, ... }: {
    _module.args.pkgs = import nixpkgs {
      config.allowUnfree = true; 
    };
    packages.gaming = (pkgs.lib.evalModules {
      modules = [
        self.wrapperModules.gaming
        { _module.args.pkgs = pkgs; }
      ];
    }).config.gaming.package;
  };

  # 3. LA LIVRAISON (Installation sur NixOS)
  flake.nixosModules.gaming = { pkgs, ... }: {

    programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        #dedicatedServer.openFirewall = true;
      };
    zramSwap.enable = true;


    imports = [
        self.nixosModules.wow
    ];
    
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.gaming
    ];
  };
}
