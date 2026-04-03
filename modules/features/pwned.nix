{ inputs, self, ... }:

{
  # 1. LE PLAN (Ton module de configuration)
  flake.wrapperModules.pwned = { pkgs, ... }: {
    # On définit ce que ce module doit produire
    # Note : On utilise 'options' et 'config' pour rester dans la logique module
    options.pwned.package = pkgs.lib.mkOption {
      type = pkgs.lib.types.package;
    };

    config.pwned.package = pkgs.symlinkJoin {
      name = "pwned-tools";
      paths = [
        pkgs.ghidra
        pkgs.gef # GEF inclut déjà GDB configuré !
        (pkgs.python3.withPackages (ps: [ ps.pwntools ]))
      ];
    };
  };

  # 2. L'USINE (Construction du paquet pour chaque système)
  perSystem = { pkgs, ... }: {
    # Au lieu d'appeler inputs.wrappers.xxx.apply, on évalue notre module
    packages.pwned = (pkgs.lib.evalModules {
      modules = [
        self.wrapperModules.pwned
        { _module.args.pkgs = pkgs; } # On injecte pkgs dans le module
      ];
    }).config.pwned.package;
  };

  # 3. LA LIVRAISON (Installation sur NixOS)
  flake.nixosModules.pwned = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.pwned
    ];
  };
}
