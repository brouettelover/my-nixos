{ pkgs, self, inputs, ... }:

{

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    GAMEMODE_PATH = "$HOME/.local/share/gamemode";
  };
  
  flake.nixosModules.wow = { pkgs, ... }: {
    environment.systemPackages = [
        pkgs.lutris
        pkgs.protonup-qt
        pkgs.mangohud
        pkgs.gamemode
        pkgs.wowup-cf
    ];
  };
}
