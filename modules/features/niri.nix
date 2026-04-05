{
  inputs,
  self,
  ...
}: {
  flake.wrapperModules.niri = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.terminal = lib.mkOption {
      type = lib.types.str;
      default = "kitty";
    };
    config = {
      settings = let
        # startNoctaliaExe = lib.getExe self.packages.${config.pkgs.stdenv.hostPlatform.system}.start-noctalia-shell;
        noctaliaExe = lib.getExe self.packages.${config.pkgs.stdenv.hostPlatform.system}.noctalia-shell;
      in {
        prefer-no-csd = null;

        input = {
          focus-follows-mouse = null;

          keyboard = {
            xkb = {
              layout = "be";
              options = "grp:alt_shift_toggle,caps:escape";
            };
            repeat-rate = 40;
            repeat-delay = 250;
          };

          touchpad = {
            natural-scroll = null;
            tap = null;
          };

          mouse = {
            accel-profile = "flat";
          };
        };

        binds = {
          "Mod+Return".spawn = config.terminal;
          
	      "Mod+Q".close-window = null;
          "Mod+F".maximize-column = null;
          "Mod+G".fullscreen-window = null;
          "Mod+Shift+F".toggle-window-floating = null;
          "Mod+C".center-column = null;

          "Mod+H".focus-column-left = null;
          "Mod+L".focus-column-right = null;
          "Mod+K".focus-window-up = null;
          "Mod+J".focus-window-down = null;

          "Mod+Left".focus-column-left = null;
          "Mod+Right".focus-column-right = null;
          "Mod+Up".focus-window-up = null;
          "Mod+Down".focus-window-down = null;

          "Mod+Shift+H".move-column-left = null;
          "Mod+Shift+L".move-column-right = null;
          "Mod+Shift+K".move-window-up = null;
          "Mod+Shift+J".move-window-down = null;

          "Mod+ampersand".focus-workspace = "w0";
          "Mod+eacute".focus-workspace = "w1";
          "Mod+quotedbl".focus-workspace = "w2";
          "Mod+quote".focus-workspace = "w3";
          "Mod+parenleft".focus-workspace = "w4";
          "Mod+section".focus-workspace = "w5";
          "Mod+egrave".focus-workspace = "w6";
          "Mod+exclam".focus-workspace = "w7";
          "Mod+ccedilla".focus-workspace = "w8";
          "Mod+agrave".focus-workspace = "w9";

          "Mod+Shift+ampersand".move-column-to-workspace = "w0";
          "Mod+Shift+eacute".move-column-to-workspace = "w1";
          "Mod+Shift+quotedbl".move-column-to-workspace = "w2";
          "Mod+Shift+quoteleft".move-column-to-workspace = "w3";
          "Mod+Shift+parenleft".move-column-to-workspace = "w4";
          "Mod+Shift+section".move-column-to-workspace = "w5";
          "Mod+Shift+egrave".move-column-to-workspace = "w6";
          "Mod+Shift+exclam".move-column-to-workspace = "w7";
          "Mod+Shift+ccedilla".move-column-to-workspace = "w8";
          "Mod+Shift+agrave".move-column-to-workspace = "w9";

          "Mod+D".spawn-sh = "${noctaliaExe} ipc call launcher toggle";
          "Mod+V".spawn-sh = ''${config.pkgs.alsa-utils}/bin/amixer sset Capture toggle'';

          "XF86AudioRaiseVolume".spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+";
          "XF86AudioLowerVolume".spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-";

          "Mod+Ctrl+H".set-column-width = "-5%";
          "Mod+Ctrl+L".set-column-width = "+5%";
          "Mod+Ctrl+J".set-window-height = "-5%";
          "Mod+Ctrl+K".set-window-height = "+5%";

          "Mod+WheelScrollDown".focus-column-left = null;
          "Mod+WheelScrollUp".focus-column-right = null;
          "Mod+Ctrl+WheelScrollDown".focus-workspace-down = null;
          "Mod+Ctrl+WheelScrollUp".focus-workspace-up = null;

          "Mod+Shift+C".spawn-sh = ''${lib.getExe config.pkgs.grim} -l 0 - | ${config.pkgs.wl-clipboard}/bin/wl-copy'';

          "Mod+Shift+V".spawn-sh = ''${config.pkgs.wl-clipboard}/bin/wl-paste | ${lib.getExe config.pkgs.swappy} -f -'';

          "Mod+Shift+S".spawn-sh = lib.getExe (config.pkgs.writeShellApplication {
            name = "screenshot";
            text = ''
              ${lib.getExe config.pkgs.grim} -g "$(${lib.getExe config.pkgs.slurp} -w 0)" - \
              | ${config.pkgs.wl-clipboard}/bin/wl-copy
            '';
          });
	};
        layout = {
          gaps = 5;

          focus-ring = {
            width = 2;
            active-color = "#${self.themeNoHash.base09}";
          };
        };

        workspaces = let
          settings = {layout.gaps = 5;};
        in {
          "w0" = settings;
          "w1" = settings;
          "w2" = settings;
          "w3" = settings;
          "w4" = settings;
          "w5" = settings;
          "w6" = settings;
          "w7" = settings;
          "w8" = settings;
          "w9" = settings;
        };

        xwayland-satellite.path =
          lib.getExe config.pkgs.xwayland-satellite;

        spawn-at-startup = [
          noctaliaExe
          (lib.getExe (
            pkgs.writeShellScriptBin "wallpaper"
            "${lib.getExe pkgs.swaybg} -i ${../../wallpapers/coffee.png} -m fill"
          ))
        ];
      };
    };
  };

  perSystem = {pkgs, ...}: {
    packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      imports = [self.wrapperModules.niri];
    };
  };

  flake.nixosModules.niri = { pkgs, lib, ... }: {
      programs.niri.enable = true;
      programs.niri.package = self.packages.${pkgs.stdenv.hostPlatform.system}.niri;
  };
}
