{ inputs, self, ... }:

{
  # 1. LE PLAN (Ton module de configuration)
  flake.wrapperModules.firefox = { pkgs, ... }: {
    # On définit ce que ce module doit produire
    options.firefox.package = pkgs.lib.mkOption {
      type = pkgs.lib.types.package;
    };

    config.firefox.package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
      # On utilise extraPolicies pour forcer l'installation de l'extension
      extraPolicies = {
        ExtensionSettings = {
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
          "FoxyProxy@erosman" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4472757/latest.xpi";
            installation_mode = "force_installed";            
          };
        };
        # Optionnel : Désactiver le premier lancement ou d'autres trucs pénibles
        DisableFirefoxAccounts = false;
        NoDefaultBookmarks = false;
      };
    };
  };

  # 2. L'USINE (Construction du paquet pour chaque système)
  perSystem = { pkgs, ... }: {
    packages.firefox = (pkgs.lib.evalModules {
      modules = [
        self.wrapperModules.firefox
        { _module.args.pkgs = pkgs; }
      ];
    }).config.firefox.package;
  };

  # 3. LA LIVRAISON (Installation sur NixOS)
  flake.nixosModules.firefox = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.firefox
    ];
  };
}
