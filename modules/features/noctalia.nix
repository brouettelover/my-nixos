{ self, inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.noctalia-shell = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs; # THIS PART IS VERY IMPORTAINT, I FORGOT IT IN THE VIDEO!!!
      extraPackages = [ pkgs.acpi ];
      settings =
        (builtins.fromJSON
          (builtins.readFile ./noctalia.json)).settings;
    };
  };
  
}
