{ inputs, ... }:

{
  flake.nixosModules.greet = { config, pkgs, ... }: {
    # sysc-greet:
    # https://github.com/Nomadcxx/sysc-greet
    # https://nomadcxx.github.io/sysc-greet/

    imports = [
      inputs.sysc-greet.nixosModules.default
    ];

    services.sysc-greet = {
      enable = true;

      # Usa Niri apenas para exibir a tela de login.
      compositor = "niri";

      # Reutiliza o Niri já disponível no Nixpkgs.
      compositorCommand = "${pkgs.niri}/bin/niri -c /etc/greetd/niri-greeter-config.kdl";
    };

    environment.systemPackages = [
      config.services.displayManager.sessionData.desktops
    ];

    environment.pathsToLink = [
      "/share/wayland-sessions"
      "/share/xsessions"
    ];
  };
}
