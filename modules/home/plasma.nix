{ inputs, ... }:
{
  flake.homeModules.plasma = { ... }: {
    imports = [
      inputs.plasma-manager.homeModules.plasma-manager
    ];
    programs.plasma = {
      enable = true;
      # Preserva configurações não declaradas.
      overrideConfig = false;
      workspace = {
        lookAndFeel = "org.kde.breezedark.desktop";
        colorScheme = "BreezeDark";
      };
    };
  };
}
