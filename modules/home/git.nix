
{
  flake.homeModules.git = { ... }: {
    # Git — documentação do Home Manager:
    # https://home-manager.dev/manual/unstable/options/home-manager/programs/git.html

    programs.git = {
      enable = true;
      package = null;

      settings = {
        user = {
          name = "mathiasd";
          email = "mathiasaug@proton.me";
        };

        init.defaultBranch = "main";

        # Facilita o primeiro push de uma branch nova.
        push.autoSetupRemote = true;

        # Remove referências remotas de branches excluídas.
        fetch.prune = true;

        # Usa o Zed como editor de commits.
        core.editor = "zeditor --wait";

        # Exibe as alterações ao escrever um commit.
        commit.verbose = true;

        # Mostra mais contexto nos conflitos de merge.
        merge.conflictStyle = "zdiff3";

        # Evita criar commits de merge automaticamente ao dar pull.
        pull.ff = "only";

        # Atalhos para comandos frequentes.
        alias = {
          st = "status";
          sw = "switch";
          br = "branch";
          last = "log -1 --oneline";
          lg = "log --oneline --graph --decorate --all";
        };
      };

      ignores = [
        "*~"
        "*.swp"
        ".DS_Store"
      ];
    };

    # Cliente SSH para autenticação no GitHub.
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      settings."github.com" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = "~/.ssh/id_ed25519";
        IdentitiesOnly = "yes";
        AddKeysToAgent = "yes";
      };
    };

    # Mantém as chaves SSH desbloqueadas durante a sessão.
    services.ssh-agent.enable = true;
  };
}
