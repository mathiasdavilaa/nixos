{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./ssd.nix
  ];

  networking.hostName = "tarnished";

  system.stateVersion = "26.05";
  home-manager.users.mad.home.stateVersion = "26.05";

  users.users.mad = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  boot.loader.limine = {
    secureBoot = {
      enable = true;
      autoGenerateKeys = true;
      autoEnrollKeys.enable = false;
    };
    extraEntries = ''
      /Windows
        protocol: efi_boot_entry
        entry: Windows Boot Manager
    '';
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
  };

  services.fstrim.enable = true;

  environment.systemPackages = with pkgs; [
    yazi
  ];
}
