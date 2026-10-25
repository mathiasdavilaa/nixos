{ inputs, ... }: {
  flake.nixosModules.nixpkgs-apps = { pkgs, ... }: {
    # Os clientes Discord/Vesktop são instalados pelo Nixcord no Home Manager.
    # Não duplicar aqui: assim as versões e os patches do Vencord
    # são escolhidos pelo próprio Nixcord.
    environment.systemPackages = with pkgs; [
      #essencials things to use computers
      ghostty
      git
      fuzzel
      lazydocker
      lazygit

      #pkgs to use on computers
      fastfetch
      zed-editor
      zapzap
      nautilus
      claude-code
      codex
      #codex-acp
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      mangohud
      prismlauncher

      #things that make computers works
      brightnessctl
      playerctl
      mpv
      imv
    ];

    programs.steam = {
      enable = true;
      extraPackages = [ pkgs.mangohud ];
    };

    programs.gamemode = {
      enable = true;
      settings.general = {
        desiredgov = "performance";
        renice = 10;
      };
    };

  };
}
