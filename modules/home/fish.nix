{ ... }: {
  flake.homeModules.fish = { config, lib, ... }: {
    # Fish — documentação do Home Manager:
    # https://nix-community.github.io/home-manager/options/home-manager/programs/fish.html

    programs.fish = {
      enable = true;

      # Executa Fastfetch ao abrir um terminal interativo,
      # somente se ele estiver habilitado no Home Manager.
      interactiveShellInit = lib.optionalString config.programs.fastfetch.enable ''
        fastfetch
      '';

      shellAliases = {
        nru = "nix flake update --flake ~/nixos";
      };

      functions = {
        # Desativa a mensagem de boas-vindas do Fish.
        fish_greeting = "";
        # Reconstrói automaticamente o host correto.
        nrs = {
          description = "Rebuild the current NixOS host";
          body = ''
            set -l host (hostnamectl --static 2>/dev/null)
            set -l profile ""
            switch $host
              case tarnished desktop
                set profile desktop
              case laptop nixos
                set profile laptop
              case '*'
                echo "NixOS profile not found: $host"
                return 1
            end
            sudo nixos-rebuild switch --flake "$HOME/nixos#$profile"
          '';
        };
        fc = {
          description = "Commit and push NixOS flake";
          body = ''
            set -l repo "$HOME/nixos"
            set -l message "flake commit"
            if test (count $argv) -gt 0
              set message (string join " " -- $argv)
            end
            git -C "$repo" add -A; or return 1
            if git -C "$repo" diff --cached --quiet
              echo "Nenhuma alteração para commitar."
              return 0
            end
            git -C "$repo" commit -m "$message"; or return 1
            git -C "$repo" push; or return 1
          '';
        };
        # Commit e push dos repositórios pessoais.
        spush = {
          description = "Commit and push wallpapers and coding repositories";
          body = ''
            set -l repos \
              "$HOME/Pictures/wallpapers" \
              "$HOME/Projects/coding"
            set -l message "sync files"
            if test (count $argv) -gt 0
              set message (string join " " -- $argv)
            end
            for repo in $repos
              echo "→ $repo"
              if not test -d "$repo"
                echo "Directory not found: $repo"
                return 1
              end
              if not test (git -C "$repo" rev-parse --show-toplevel 2>/dev/null) = "$repo"
                echo "Not a Git repository root: $repo"
                return 1
              end
              git -C "$repo" add -A; or return 1
              if not git -C "$repo" diff --cached --quiet
                git -C "$repo" commit -m "$message"; or return 1
              else
                echo "No changes to commit."
              end
              git -C "$repo" push; or return 1
            end
          '';
        };
        # Pull dos repositórios pessoais.
        spull = {
          description = "Pull wallpapers and coding repositories";
          body = ''
            set -l repos \
              "$HOME/Pictures/wallpapers" \
              "$HOME/Projects/coding"
            for repo in $repos
              echo "→ $repo"
              if not test -d "$repo"
                echo "Directory not found: $repo"
                return 1
              end
              if not test (git -C "$repo" rev-parse --show-toplevel 2>/dev/null) = "$repo"
                echo "Not a Git repository root: $repo"
                return 1
              end
              git -C "$repo" pull --ff-only; or return 1
            end
          '';
        };
      };
    };
  };
}
