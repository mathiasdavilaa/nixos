# Este arquivo monta desktop/laptop e conecta os módulos criados em modules/.
# Normalmente você não precisa editá-lo para instalar ou configurar programas.
{ config, inputs, ... }:
let
  mkHost = { hostModule, username }:
    inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        inputs.home-manager.nixosModules.home-manager
        inputs.nix-flatpak.nixosModules.nix-flatpak
        hostModule

        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;

            # Preserva arquivos preexistentes antes de o Home Manager
            # substitui-los por links gerenciados declarativamente.
            # Evita a falha "Existing file ... would be clobbered".
            backupFileExtension = "hm-backup-20261025";

            users.${username} = {
              # Os módulos Home Manager são reunidos automaticamente.
              imports = builtins.attrValues config.flake.homeModules;
              home.username = username;
              home.homeDirectory = "/home/${username}";
            };
          };
        }
      ] ++ builtins.attrValues config.flake.nixosModules;
    };
in
{
  flake.nixosConfigurations = {
    desktop = mkHost {
      hostModule = ../hosts/desktop;
      username = "mad";
    };

    laptop = mkHost {
      hostModule = ../hosts/laptop;
      username = "mathias"; # Ajuste se usar outro usuário no laptop.
    };
  };
}
