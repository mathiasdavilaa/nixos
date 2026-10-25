# Boot compartilhado: mesmos parâmetros Limine nos dois hosts.
# Secure Boot e a entrada do Windows são exclusivos do desktop.
{
  flake.nixosModules.boot = { pkgs, ... }: {
    boot.loader.systemd-boot.enable = false;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.limine = {
      enable = true;
      efiSupport = true;
      maxGenerations = 5;
    };

    environment.systemPackages = with pkgs; [
      sbctl
      efibootmgr
    ];
  };
}
