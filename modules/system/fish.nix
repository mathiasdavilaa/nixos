# Fish — documentação:
# https://wiki.nixos.org/wiki/Fish

{ ... }: {
  flake.nixosModules.fish = { ... }: {
    programs.fish.enable = true;
  };
}
