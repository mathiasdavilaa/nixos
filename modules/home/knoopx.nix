{ inputs, ... }: {
  flake.homeModules.knoopx = { pkgs, ... }: {
    imports = [
      inputs.knoopx.homeManagerModules.default
    ];

    services.astal-shell = {
      enable = true;

      package = inputs.knoopx.packages.${pkgs.stdenv.hostPlatform.system}.default;

      theme = {
        iconTheme = "Yaru";

        background = {
          primary = "rgba(30, 30, 46, 1.0)";
          secondary = "rgba(24, 24, 37, 1.0)";
        };

        text = {
          primary = "rgba(205, 214, 244, 1.0)";
          secondary = "rgba(186, 194, 222, 0.7)";
        };
      };
    };
  };
}
