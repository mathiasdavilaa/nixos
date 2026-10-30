# Sessões gráficas mínimas que existiam no flake antigo.
# A configuração pessoal do Niri e a shell iNiR NÃO foram copiadas aqui.
{
  flake.nixosModules.desktop = { pkgs, ... }: {
    services.xserver.enable = true;
    services.xserver.xkb.layout = "us";

    #services.displayManager.sddm = {
    #  enable = true;
    #  wayland.enable = true;
    #};
    #services.displayManager.defaultSession = "niri";

    programs.niri.enable = true;
    services.desktopManager.plasma6.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome
        xdg-desktop-portal-gtk
      ];
      config.niri.default = [
        "gnome"
        "gtk"
      ];
    };
  };
}
