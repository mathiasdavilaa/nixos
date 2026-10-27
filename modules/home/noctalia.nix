{ ... }: {
  flake.homeModules.noctalia = { inputs, ... }: {
    imports = [
      inputs.noctalia.homeModules.default
    ];

    programs.noctalia = {
      enable = false;
      systemd.enable = false;
    };
  };
}
