{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    lutris
    protonup-qt
    mangohud
    gamemode
    wowup-cf
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    GAMEMODE_PATH = "$HOME/.local/share/gamemode";
  };
  
}
