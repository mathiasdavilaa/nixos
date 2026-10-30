# OpenCode com OpenAI/ChatGPT, mantendo os CLIs Codex e Claude Code existentes.
# Coloque em modules/home/opencode.nix e remova o antigo ai-agents.nix.
# O import-tree registra este módulo no Home Manager dos dois hosts.
# https://opencode.ai/v2/docs/providers/#chatgpt
# https://opencode.ai/v2/docs/models/
{ inputs, ... }:
{
  flake.homeModules.opencode =
    { pkgs, ... }:
    let
      # Mantém o Nixpkgs principal (26.05) e usa unstable apenas para estas ferramentas.
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
        ripgrep
        fd
        jq
        bubblewrap
        socat
      ];

      # Usa a integração nativa OpenAI/ChatGPT.
      # Após o rebuild, execute `opencode auth login` e selecione OpenAI/ChatGPT.
      # O login fica a cargo do próprio OpenCode, fora da configuração Nix.
      # A revisão atual de programs.opencode falha ao usar package = null.
      # O Home Manager gerencia o JSON diretamente; o pacote fica no NixOS.
      xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
        "$schema" = "https://opencode.ai/config.json";
        # A versão do programa é atualizada pelo flake.
        # Formato aceito pelo OpenCode 1.x e normalizado pelo 2.x.
        autoupdate = false;
        model = "openai/gpt-6.1-sol";

        provider.openai.models."gpt-6.1-sol".options = {
          reasoningEffort = "high";
        };
      };

      # As opções abaixo continuam valendo para os CLIs independentes.
      # O OpenCode executa seu próprio agente usando os modelos da OpenAI;
      # ele não executa o Codex CLI nem herda seu sandbox ou suas regras.
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
              {
                path = "~/.ssh";
                mode = "deny";
              }
              {
                path = "~/.aws";
                mode = "deny";
              }
              {
                path = "~/.gnupg";
                mode = "deny";
              }
            ];
          };
        };
      };
    };
}
