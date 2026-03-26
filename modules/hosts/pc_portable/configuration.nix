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
    # ...
  };

}
