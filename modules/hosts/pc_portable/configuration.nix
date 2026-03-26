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

    ];
    
    boot = {
      loader.grub.enable = true;
      loader.grub.efiSupport = true;
      loader.grub.efiInstallAsRemovable = true;

      supportedFilesystems.ntfs = true;

      kernelParams = ["quiet"];
      kernelModules = [ "kvm_amd" "coretemp" "cpuid" "v4l2loopback" ];
      


    };
  };

}
