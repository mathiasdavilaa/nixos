# Flatpaks declarativos (instalação no sistema, em ambos os hosts).
{
  flake.nixosModules.flatpak-apps = { ... }: {
    services.flatpak = {
      enable = true;

      packages = [
        "org.vinegarhq.Sober"
      ];

      # Não remova Flatpaks instalados manualmente enquanto estuda o template.
      uninstallUnmanaged = false;
      update.onActivation = false;
    };
  };
}
