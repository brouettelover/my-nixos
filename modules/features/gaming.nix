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
        pkgs.wineWow64Packages.stable
        pkgs.winetricks
        pkgs.mangohud
      ];

    };
  };

  # 2. L'USINE (Construction du paquet pour chaque système)
  perSystem = { system, ... }: 
    let
    # ON FORCE L'UNFREE ICI pour que Lutris puisse être construit
      pkgsUnfree = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
    # On utilise pkgsUnfree au lieu du pkgs standard
      packages.gaming = (pkgsUnfree.lib.evalModules {
        modules = [
          self.wrapperModules.gaming
          { _module.args.pkgs = pkgsUnfree; }
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
    # 4 Gio de RAM sont réservés à l'iGPU : il ne reste que ~11 Gio pour WoW
    # + Battle.net. zstd compresse ~3:1, donc 50 % de la RAM en zram donne
    # l'équivalent de plusieurs Gio utiles sans jamais toucher le disque.
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 50;
      priority = 100;
    };


    imports = [
        self.nixosModules.wow
    ];
    
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.gaming
    ];
  };
}
