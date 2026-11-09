{ self, ... }: {
  perSystem = { pkgs, ... }: {
    packages.plymouth-ghibli-theme = pkgs.runCommand "plymouth-ghibli-theme" { } ''
      themeDir=$out/share/plymouth/themes/ghibli
      mkdir -p "$themeDir"
      cp ${./plymouth-ghibli/ghibli.script} "$themeDir/ghibli.script"
      cp ${./plymouth-ghibli/soot_sprite.png} "$themeDir/soot_sprite.png"
      cp ${./plymouth-ghibli/firefly.png} "$themeDir/firefly.png"
      cp ${./plymouth-ghibli/progress_bar.png} "$themeDir/progress_bar.png"
      substitute ${./plymouth-ghibli/ghibli.plymouth} "$themeDir/ghibli.plymouth" \
        --subst-var-by out "$out"
    '';
  };

  flake.nixosModules.plymouth_ghibli = { pkgs, ... }: {
    boot.plymouth = {
      enable = true;
      themePackages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.plymouth-ghibli-theme ];
      theme = "ghibli";
    };
  };
}
