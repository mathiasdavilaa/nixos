# Codex CLI + Claude Code, independentemente do Zed.
# Coloque em modules/home/ai-agents.nix.
# Este modulo e descoberto pelo import-tree e registrado no Home Manager.
{ inputs, ... }:
{
  flake.homeModules.ai-agents =
    { pkgs, ... }:
    let
      # Evita misturar o nixpkgs principal (26.05) com os agentes mais recentes.
      # O Claude Code e unfree, por isso habilitamos allowUnfree somente aqui.
      unstable = import inputs.nixpkgs-unstable {
        system = pkgs.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
    in
    {
      # Ferramentas utilitarias que os agentes costumam utilizar no terminal.
      # Inclui as dependencias do sandbox Linux do Claude Code.
      home.packages = with pkgs; [
        git
        ripgrep
        fd
        jq
        bubblewrap
        socat
      ];

      # Codex CLI: executa normalmente com `codex` no terminal ou por SSH.
      programs.codex = {
        enable = true;
        package = unstable.codex;

        settings = {
          approval_policy = "on-request";
          sandbox_mode = "workspace-write";
          sandbox_workspace_write.network_access = false;
        };

        # Regras adicionais para operacoes de maior impacto.
        # Nao substituem o sandbox ou a revisao dos comandos sugeridos.
        rules.safety = ''
          prefix_rule(pattern = ["git", "push"], decision = "prompt")
          prefix_rule(pattern = ["git", "clean"], decision = "prompt")
          prefix_rule(pattern = ["git", "reset", "--hard"], decision = "prompt")
          prefix_rule(pattern = ["sudo"], decision = "prompt")
          prefix_rule(pattern = ["nixos-rebuild"], decision = "prompt")
          prefix_rule(pattern = ["rm", "-rf"], decision = "prompt")
        '';
      };

      # Claude Code CLI: executa normalmente com `claude` no terminal ou por SSH.
      programs.claude-code = {
        enable = true;
        package = unstable.claude-code;

        settings = {
          permissions = {
            # Permite edicoes normais de codigo sem perguntar a cada arquivo.
            defaultMode = "acceptEdits";
            disableBypassPermissionsMode = "disable";

            # Estes comandos continuam exigindo sua autorizacao.
            ask = [
              "Bash(git push *)"
              "Bash(git clean *)"
              "Bash(git reset --hard *)"
              "Bash(sudo *)"
              "Bash(nixos-rebuild *)"
              "Bash(rm -rf *)"
              "Bash(dangerouslyDisableSandbox:true)"
            ];

            # Regras para ferramentas de leitura do proprio Claude.
            deny = [
              "Read(~/.ssh/**)"
              "Read(~/.aws/**)"
              "Read(~/.gnupg/**)"
              "Read(**/.env)"
              "Read(**/.env.local)"
            ];
          };

          sandbox = {
            enabled = true;
            autoAllowBashIfSandboxed = true;
            failIfUnavailable = true;

            # Comandos incompativeis com o sandbox poderao pedir sua
            # aprovacao antes de uma tentativa fora dele.
            allowUnsandboxedCommands = true;

            # Protege credenciais tambem contra comandos Bash sandboxed.
            credentials.files = [
              { path = "~/.ssh"; mode = "deny"; }
              { path = "~/.aws"; mode = "deny"; }
              { path = "~/.gnupg"; mode = "deny"; }
            ];
          };
        };
      };
    };
}
