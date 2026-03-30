{ inputs, self, ... }:

{
    flake.wrapperModules.pwned = { pkgs, lib, ... }: {
      options.pwned.enable = true;
      
      config = {
        package = pkgs.symlinkJoin {
          name = "pwned-tools";
          paths = [
            (pkgs.python3.withPackages (ps: [ ps.pwntools ]))
            pkgs.gdb
            pkgs.gef # GEF est déjà dans nixpkgs !
          ];
        };
      };
    };
    
    perSystem = { pkgs, ... }: {
        packages.pwned = (pkgs.lib.evalModules {
          modules = [
            self.wrapperModules.pwned
         { _module.args.pkgs = pkgs; } # On injecte pkgs dans le module
        ];
        }).config.pwned.package;
    };

    flake.nixosModules.pwned = { pkgs, ... }: {
      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.pwned
      ];
    };


}
