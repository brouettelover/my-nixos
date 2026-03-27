{ pkgs, ... }:

{
  home.packages = with pkgs; [
    lutris
    protonup-qt
    mangohud
    gamemode
    wowup-cf
  ];

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    GAMEMODE_PATH = "$HOME/.local/share/gamemode";
    };
  
  }
