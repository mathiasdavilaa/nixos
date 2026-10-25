# Lista de AppImages instalados nos dois computadores.
{
  flake.nixosModules.appimage-apps = { pkgs, ... }: {
    environment.systemPackages = [
      (pkgs.callPackage ./_appimages/liner.nix { inherit pkgs; })
    ];
  };
}
