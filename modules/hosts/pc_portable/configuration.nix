{ self, inputs, ... }: {

  flake.nixosModules.pc_portable_configuration = { pkgs, lib, ... }: {
    # import any other modules from here
    imports = [
      self.nixosModules.pc_portable_hardware_configuration
      self.nixosModules.niri
    ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    environment.systemPackages = with pkgs; [
      firefox
      vim
      wget
      btop
      bat
      git

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

      plymouth.enable = true; # animation au boot
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
    
    xdg.portal.extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
    xdg.portal.enable = true;
    xdg.portal.config.common.default = [ "gnome" "gtk" ]; 

    nix = {
      settings.auto-optimise-store = true; # Saves space by hardlinking files
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    };
    

    programs.niri.enable = true;

    time.timeZone = "Europe/Brussels";
 
    system.stateVersion = "25.11";
  };

}
