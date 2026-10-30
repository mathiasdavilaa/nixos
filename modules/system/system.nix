# Configuração básica compartilhada entre desktop e laptop.
# Adaptado de modules/system/base.nix do flake antigo.
{
  flake.nixosModules.system = { pkgs, ... }: {
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    nix.optimise.automatic = true;
    nixpkgs.config.allowUnfree = true; # Discord/Claude e outros pacotes do exemplo.
    networking.networkmanager.enable = true;

    # Mesmo fuso e preferências regionais do flake antigo.
    time.timeZone = "America/Sao_Paulo";
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = builtins.listToAttrs (
      map
        (name: {
          inherit name;
          value = "pt_BR.UTF-8";
        })
        [
          "LC_ADDRESS"
          "LC_IDENTIFICATION"
          "LC_MEASUREMENT"
          "LC_MONETARY"
          "LC_NAME"
          "LC_NUMERIC"
          "LC_PAPER"
          "LC_TELEPHONE"
          "LC_TIME"
        ]
    );

    fonts.enableDefaultPackages = true;
    fonts.packages = with pkgs; [
      nerd-fonts.symbols-only
      nerd-fonts.geist-mono
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];

    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Mantém as condições básicas para uma sessão Wayland.
    security.polkit.enable = true;
    services.upower.enable = true;
    services.power-profiles-daemon.enable = true;
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
  };
}
