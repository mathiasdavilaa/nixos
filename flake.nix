{
  description = "simple flake made by @madd4";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:denful/import-tree";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-flatpak.url = "github:gmodena/nix-flatpak?ref=v0.8.0";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    zen-browser.inputs.home-manager.follows = "home-manager";

    sysc-greet.url = "github:Nomadcxx/sysc-greet";
    sysc-greet.inputs.nixpkgs.follows = "nixpkgs";

    nixcord.url = "github:4evy/nixcord";
    nixcord.inputs.nixpkgs.follows = "nixpkgs";
    nixcord.inputs.home-manager.follows = "home-manager";

    knoopx.url = "github:knoopx/astal-shell";

    noctalia.url = "github:noctalia-dev/noctalia";
    noctalia.inputs.nixpkgs.follows = "nixpkgs";

    areofyl-fetch.url = "github:areofyl/fetch";

    plasma-manager.url = "github:nix-community/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";

  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.home-manager.flakeModules.home-manager
        (inputs.import-tree ./modules)
      ];

      systems = [ "x86_64-linux" ];

      perSystem = { pkgs, ... }: {
        formatter = pkgs.nixfmt;
      };
    };
}
