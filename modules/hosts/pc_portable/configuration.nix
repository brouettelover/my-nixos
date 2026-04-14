{ self, inputs, ... }: {

  flake.nixosModules.pc_portable_configuration = { pkgs, lib, ... }: {
    nixpkgs.config.allowUnfree = true;    
    # import any other modules from here
    imports = [
      self.nixosModules.pc_portable_hardware_configuration
      self.nixosModules.niri
      self.nixosModules.fish
      self.nixosModules.gaming
      self.nixosModules.neovim
      self.nixosModules.kitty
      self.nixosModules.pwned
      self.nixosModules.firefox
      self.nixosModules.web_exploit
      self.nixosModules.network_analysis
      self.nixosModules.network_exploit
      self.nixosModules.file_manager
    ];


    programs.nix-ld.enable = true;
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    environment.systemPackages = with pkgs; [
      vim
      wget
      btop
      bat
      git
      unzip
      wl-clipboard
      python3
      keepassxc
      cage
      mullvad-vpn
      quickemu      
    ];
     
    boot = {
      #kernelPackages = pkgs.linuxPackages_latest;

      loader.systemd-boot.enable = true;
      loader.efi.canTouchEfiVariables = true;
      #loader.grub.enable = true;
      #loader.grub.efiSupport = true;
      #loader.grub.efiInstallAsRemovable = true;

      supportedFilesystems.ntfs = true;

      kernelParams = ["quiet"];
      kernelModules = [ "kvm_amd" "coretemp" "cpuid" "v4l2loopback" ];
      #cotemp -> temperature
      #kvm_amd -> pour qemu
      #v4l2 -> option dans teams,zoom,...

      plymouth = {
        enable = true; # animation au boot
         # 1. On ne prend QUE le thème qui nous intéresse
            themePackages = [
            (pkgs.adi1090x-plymouth-themes.override {
                selected_themes = [ "cross_hud" ]; # <--- Remplace par ton préféré (ex: "target", "spinner", etc.)
            })
        ];

        # 2. On spécifie le même nom ici
        theme = "cross_hud";
      };
    };
    
    users.users.jongleur = {
      isNormalUser = true;
      description = "jongleur";
      extraGroups = [ "networkmanager" "wheel" ];
    };

    networking = {
      hostName = "pc-portable";
      networkmanager.enable = true;
    };


    # DON T KNOW IF IT USEFULL
    # Select internationalisation properties.
    i18n.defaultLocale = "fr_BE.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "fr_BE.UTF-8";
      LC_IDENTIFICATION = "fr_BE.UTF-8";
      LC_MEASUREMENT = "fr_BE.UTF-8";
      LC_MONETARY = "fr_BE.UTF-8";
      LC_NAME = "fr_BE.UTF-8";
      LC_NUMERIC = "fr_BE.UTF-8";
      LC_PAPER = "fr_BE.UTF-8";
      LC_TELEPHONE = "fr_BE.UTF-8";
      LC_TIME = "fr_BE.UTF-8";
    };

    # Configure console keymap
    console.keyMap = "be-latin1";
    #######
    hardware.bluetooth.enable = true;
    hardware.cpu.amd.updateMicrocode = true;
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
    boot.initrd.kernelModules = [ "amdgpu" ];
    services = {
      #blueman.enable = true; #Bluetooth_GUI
      printing.enable = true; #Imprimante
      xserver.videoDrivers = [ "amdgpu" ];
    };
    services.upower.enable = true; # show battery
    xdg.portal.extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
    xdg.portal.enable = true;
    xdg.portal.config.common.default = [ "gnome" "gtk" ]; 

    nix = {
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    };
    
    services.greetd = {
      enable = true;
      settings = {
        default_session =  {
	      command = "${lib.getExe pkgs.cage} -s -- ${lib.getExe pkgs.greetd.regreet}"
	      user = "jongleur";
	    };
      };
    };

    programs.regreet = {
      enable = true;
      settings = {
        general = {
          default_session = "niri";
        };
        background = {
          path = "/home/jongleur/nixos_v2/wallpapers/space.png"; # Change le chemin !
          fit = "Cover";
        };
        gtktremedy = {
          theme_name = "Adwaita-dark";
          cursor_theme_name = "Bibata-Modern-Classic";
          font_name = "Cantarell 11";
        };
      };
    };
    # VPN Settings
    services.mullvad-vpn.enable = true;
    services.mullvad-vpn.package = pkgs.mullvad-vpn;
    services.resolved.enable = true;
    services.gvfs.enable = true; # Add usb mount in file manager   
    services.udisks2.enable = true; # auto mount usb
    services.devmon.enable = true; # auto mount usb

    systemd.services.greetd.serviceConfig =  {
      Type = "idle";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal";
      TTYReset = true;
      TTYVHangup = true;
      TTYDisallocate = true;
    };
    #programs.niri.enable = true;

    time.timeZone = "Europe/Brussels";
 
    system.stateVersion = "25.11";
  };

}
