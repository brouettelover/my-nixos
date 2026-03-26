{ self, inputs, ... }: {
  flake.nixosConfigurations.pc_portable = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.pc_portable_configuration
    ];
  };
}
