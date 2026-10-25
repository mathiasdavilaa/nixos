{ pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "nixos";

  # Preserva os valores existentes no flake antigo.
  system.stateVersion = "26.05";
  home-manager.users.mathias.home.stateVersion = "26.05";

  users.users.mathias = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  environment.systemPackages = with pkgs; [
    proton-vpn
  ];
}
