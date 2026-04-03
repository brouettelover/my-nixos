{ pkgs, self, inputs, ... }:

{

  flake.nixosModules.wow = { pkgs, ... }: {
    environment.sessionVariables = {  
      NIXOS_OZONE_WL = "1";
      GAMEMODE_PATH = "$HOME/.local/share/gamemode";
    };
 
    environment.systemPackages = [
        pkgs.protonup-qt
        pkgs.wowup-cf
    ];
  };
}
