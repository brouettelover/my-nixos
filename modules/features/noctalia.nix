{ self, inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.noctalia-shell = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs; # THIS PART IS VERY IMPORTAINT, I FORGOT IT IN THE VIDEO!!!
      settings =
        (builtins.fromJSON
          (builtins.readFile ./noctalia.json)).settings;
    };
  };

  flake.nixosModules.noctalia = { ... }: {
    # Deploy the custom "Ghibli" predefined color scheme into noctalia's
    # user-scheme directory, so it shows up alongside the built-in ones.
    systemd.tmpfiles.rules = [
      "d /home/jongleur/.config/noctalia 0755 jongleur users -"
      "d /home/jongleur/.config/noctalia/colorschemes 0755 jongleur users -"
      "d /home/jongleur/.config/noctalia/colorschemes/Ghibli 0755 jongleur users -"
      "L+ /home/jongleur/.config/noctalia/colorschemes/Ghibli/Ghibli.json - - - - ${./noctalia-ghibli-scheme.json}"
    ];
  };
}
