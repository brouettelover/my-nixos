{ inputs, self, ... }:

{
    flake.wrapperModules.pwned = { pkgs, lib, ... }: {
      options.pwned = {
        enableGef = true;
        extraPythonPackages = ps: [ ps.pwntools ];
      };
      
      config = {
        package = pkgs.symlinkJoin {
          name = "pwned-env";
          paths = [
            (pkgs.python3.withPackages (ps: [ ps.pwntools ]))
            pkgs.gdb
            pkgs.gef # GEF est déjà dans nixpkgs !
          ];
        };
      };
    };
    
    perSystem = { pkgs, ... }: {
      packages.pwned = (inputs.wrappers.wrapperModules.pwned.apply {
        inherit pkgs;
        # On importe notre module de définition
        imports = [ self.wrapperModules.pwned ];
        # On peut même surcharger des trucs ici si on veut
      }).wrapper;
    };

    flake.nixosModules.pwned = { pkgs, ... }: {
      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.pwned;
      ];
    };


}
