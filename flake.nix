{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Nixpkgs plus récent que le nixpkgs principal, utilisé seulement pour
    # wowup-cf : WoW Forever (sorti le 4/11/2026) n'est reconnu qu'à partir
    # de wowup-cf 2.24.1, pas encore présent dans la nixpkgs principale sans
    # casser noctalia-shell (renommé en noctalia côté wrapper-modules).
    nixpkgs-wowup.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";
    wrapper-modules.inputs.nixpkgs.follows = "nixpkgs";
    wrappers.url = "github:lassulus/wrappers";
    wrappers.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);
}
