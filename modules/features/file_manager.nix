{ inputs, self, ... }:

{
  # 1. LE PLAN (Ton module de configuration)
  flake.wrapperModules.file_manager = { pkgs, ... }: {
    # On définit ce que ce module doit produire
    options.file_manager.package = pkgs.lib.mkOption {
      type = pkgs.lib.types.package;
    };

    config.file_manager.package = pkgs.symlinkJoin {
      name = "file_manager-tools";
      paths = [
        pkgs.thunar
        pkgs.thunar-archive-plugin
        pkgs.thunar-dropbox-plugin
        pkgs.thunar-media-tags-plugin
        pkgs.thunar-vcs-plugin
        pkgs.thunar-volman
      ];
    };
  };

  # 2. L'USINE (Construction du paquet pour chaque système)
  perSystem = { pkgs, self', ... }: {
    packages.file_manager = (pkgs.lib.evalModules {
      modules = [
        self.wrapperModules.file_manager
        { _module.args.pkgs = pkgs; }
      ];
    }).config.file_manager.package;

    # imv n'expose pas de .desktop dans nixpkgs : on en fournit un pour
    # pouvoir en faire l'application par défaut des images dans Thunar.
    packages.imv-desktop = pkgs.makeDesktopItem {
      name = "imv";
      desktopName = "imv";
      exec = "${pkgs.lib.getExe pkgs.imv} %f";
      icon = "imv";
      mimeTypes = [
        "image/png"
        "image/jpeg"
        "image/gif"
        "image/bmp"
        "image/webp"
        "image/tiff"
        "image/svg+xml"
      ];
      categories = ["Graphics" "Viewer"];
    };

    # Éditeur de texte par défaut : neovim dans kitty.
    packages.nvim-kitty-desktop = pkgs.makeDesktopItem {
      name = "nvim-kitty";
      desktopName = "Neovim (kitty)";
      exec = "${pkgs.lib.getExe self'.packages.kitty} -e ${pkgs.lib.getExe self'.packages.neovim} %F";
      icon = "nvim";
      terminal = false;
      mimeTypes = ["text/plain"];
      categories = ["Utility" "TextEditor"];
    };
  };

  # 3. LA LIVRAISON (Installation sur NixOS)
  flake.nixosModules.file_manager = { pkgs, ... }: let
    system = pkgs.stdenv.hostPlatform.system;
    selfPkgs = self.packages.${system};
  in {
    environment.systemPackages = [
      selfPkgs.file_manager
      pkgs.imv
      pkgs.xreader
      pkgs.tumbler
      pkgs.ffmpegthumbnailer
      selfPkgs.imv-desktop
      selfPkgs.nvim-kitty-desktop
    ];

    # Associations par défaut : images -> imv, PDF -> xreader, texte -> nvim+kitty.
    environment.etc."xdg/mimeapps.list".text = ''
      [Default Applications]
      image/png=imv.desktop
      image/jpeg=imv.desktop
      image/gif=imv.desktop
      image/bmp=imv.desktop
      image/webp=imv.desktop
      image/tiff=imv.desktop
      image/svg+xml=imv.desktop
      application/pdf=xreader.desktop
      text/plain=nvim-kitty.desktop
    '';
  };
}
