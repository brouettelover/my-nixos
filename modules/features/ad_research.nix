{ inputs, self, ... }:

{
  # 1. LE PLAN (Ton module de configuration)
  # Outils de reconnaissance / analyse Active Directory : énumération,
  # cartographie, inspection de protocole. Pas d'outils d'exploitation
  # active (spray, dumping de creds, shell post-exploitation).
  flake.wrapperModules.ad_research = { pkgs, ... }: {
    options.ad_research.package = pkgs.lib.mkOption {
      type = pkgs.lib.types.package;
    };

    config.ad_research.package = pkgs.symlinkJoin {
      name = "ad_research-tools";
      paths = [
        pkgs.nmap
        pkgs.ldapdomaindump
        pkgs.ldeep
        pkgs.smbmap
        pkgs.enum4linux-ng
        pkgs.bloodhound-py
        (pkgs.python3.withPackages (ps: [ ps.impacket ]))
      ];
    };
  };

  # 2. L'USINE (Construction du paquet pour chaque système)
  perSystem = { pkgs, ... }: {
    packages.ad_research = (pkgs.lib.evalModules {
      modules = [
        self.wrapperModules.ad_research
        { _module.args.pkgs = pkgs; }
      ];
    }).config.ad_research.package;
  };

  # 3. LA LIVRAISON (Installation sur NixOS)
  flake.nixosModules.ad_research = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.ad_research
    ];
  };
}
