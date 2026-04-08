{ pkgs, self, inputs, ... }:

{
  
  flake.wrapperModules.wow = { pkgs, ... }: {
    options.wow.package = pkgs.lib.mkOption {
        type = pkgs.lib.types.package;
    };

    config.wow.package = pkgs.symlinkJoin {
        name = "wow on steam";
        paths = [
            pkgs.lutris
            pkgs.protonup-qt
            pkgs.mangohud
            pkgs.gamemode
            pkgs.wowup-cf
        ];
        
    };

  };
  flake.nixosModules.wow = { pkgs, ... }: {
    environment.sessionVariables = {  
      NIXOS_OZONE_WL = "1";
      GAMEMODE_PATH = "$HOME/.local/share/gamemode";
    };
 
    environment.systemPackages = [
            ];
  };
}
