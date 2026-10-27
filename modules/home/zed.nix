# Zed — configuracao via Home Manager (flake-parts + import-tree).
# O Zed e as ferramentas de desenvolvimento sao instalados pelo NixOS.
# Documentacao:
# https://zed.dev/docs/configuring-zed
# https://zed.dev/docs/tasks
# https://zed.dev/docs/debugger
# https://zed.dev/docs/ai/external-agents
# https://github.com/nix-community/nixd/blob/main/nixd/docs/configuration.md
{ inputs, ... }:
{
  flake.homeModules.zed =
    { config, pkgs, ... }:
    let
      # Host correspondente aos usuarios definidos no flake.
      host = if config.home.username == "mad" then "desktop" else "laptop";
      flakePath = "${config.home.homeDirectory}/nixos";
      nixosConfig = "(builtins.getFlake \"${flakePath}\").nixosConfigurations.${host}";

      # Usa os pacotes recentes somente para os agentes, sem atualizar o sistema.
      # allowUnfree e necessario porque o Claude Code e um binario proprietario.
      unstablePkgs = import inputs.nixpkgs-unstable {
        system = pkgs.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
      codexAcp = unstablePkgs.codex-acp;
      claudeAcp = unstablePkgs.claude-agent-acp;

      # Tarefas executam scripts Bash mesmo usando Fish como shell padrao.
      bash = "${pkgs.bash}/bin/bash";
    in
    {
      # Adaptadores ACP instalados de forma declarativa.
      home.packages = [ codexAcp claudeAcp ];

      programs.zed-editor = {
        enable = true;
        package = null; # Zed ja esta em environment.systemPackages.

        # A instalacao das extensoes ainda e feita pelo proprio Zed.
        extensions = [
          "nix"
          "toml"
          "make"
          "dockerfile"
          "material-icon-theme"
        ];

        # Permite usar a interface do Zed para personalizar os ajustes.
        # Os valores declarados abaixo serao reaplicados pelo Home Manager.
        mutableUserSettings = true;

        userSettings = {
          theme = {
            mode = "dark";
            dark = "One Dark";
            light = "One Light";
          };
          icon_theme = "Material Icon Theme";

          ui_font_family = "GeistMono Nerd Font";
          buffer_font_family = "GeistMono Nerd Font";
          ui_font_size = 16;
          buffer_font_size = 14;
          vim_mode = false;

          tab_size = 2;
          soft_wrap = "none";
          show_whitespaces = "selection";
          use_smartcase_search = true;
          show_completions_on_input = true;
          show_completion_documentation = true;
          use_autoclose = true;
          inlay_hints.enabled = true;
          remove_trailing_whitespace_on_save = true;
          ensure_final_newline_on_save = true;

          project_panel = {
            dock = "right";
            default_width = 300;
            git_status = true;
          };
          minimap.show = "never";
          diagnostics.inline.enabled = true;
          git.inline_blame.enabled = false;

          telemetry = {
            metrics = false;
            diagnostics = false;
          };

          load_direnv = "direct";
          terminal = {
            shell = "system";
            font_family = "GeistMono Nerd Font";
            font_size = 14;
            working_directory = "current_project_directory";
          };

          file_scan_exclusions = [
            "**/.direnv"
            "**/node_modules"
            "**/build"
            "**/outputs"
            "**/result"
            "**/result-*"
            "..." # Preserva exclusoes padrao do Zed.
          ];

          languages = {
            Nix = {
              tab_size = 2;
              language_servers = [
                "nixd"
                "!nil"
              ];
              format_on_save = "on";
              formatter.external = {
                command = "${pkgs.nixfmt}/bin/nixfmt";
                arguments = [ ];
              };
            };

            C = {
              tab_size = 4;
              language_servers = [ "clangd" ];
              format_on_save = "on";
              formatter.language_server.name = "clangd";
            };

            "C++" = {
              tab_size = 4;
              language_servers = [ "clangd" ];
              format_on_save = "on";
              formatter.language_server.name = "clangd";
            };

            Python = {
              tab_size = 4;
              language_servers = [
                "basedpyright"
                "ruff"
              ];
              format_on_save = "on";
              code_actions_on_format."source.organizeImports.ruff" = true;
              formatter.language_server.name = "ruff";
            };
          };

          # Autocomplete de pkgs.* e das opcoes declaradas neste flake.
          lsp.nixd.settings = {
            nixpkgs.expr = "import ${pkgs.path} { system = \"${pkgs.stdenv.hostPlatform.system}\"; config.allowUnfree = true; }";
            options = {
              nixos.expr = "${nixosConfig}.options";
              "home-manager".expr = "${nixosConfig}.options.home-manager.users.type.getSubOptions []";
            };
            formatting.command = [ "${pkgs.nixfmt}/bin/nixfmt" ];
          };

          # Agentes externos ACP gerenciados pelo Nix, sem ACP Registry.
          agent_servers = {
            "Codex (NixOS)" = {
              type = "custom";
              command = "${codexAcp}/bin/codex-acp";
              args = [ ];
              env = {
                # Edita arquivos do projeto no sandbox; pede escalacao fora dele.
                INITIAL_AGENT_MODE = "workspace-write";
                CODEX_CONFIG = builtins.toJSON {
                  approval_policy = "on-request";
                  sandbox_mode = "workspace-write";
                };
              };
            };
            "Claude Code (NixOS)" = {
              type = "custom";
              command = "${claudeAcp}/bin/claude-agent-acp";
              args = [ ];
              env = { };
            };
          };

          # Camada de aprovacao do Zed. A configuracao nativa de cada agente
          # tambem continua valendo; "allow" aqui nao desabilita seu sandbox.
          agent.tool_permissions = {
            default = "allow";
            tools = {
              terminal = {
                # Comandos nao reconhecidos pedem permissao; os triviais passam.
                default = "confirm";
                always_allow = [
                  { pattern = "^git\\s+(status|log|diff|show)\\b"; }
                  { pattern = "^nix\\s+(eval|flake\\s+(check|show))\\b"; }
                  { pattern = "^(rg|grep|ls|pwd|cat|head|tail|fd)\\b"; }
                ];
                always_confirm = [
                  { pattern = "\\bsudo\\b"; }
                  { pattern = "\\bnixos-rebuild\\b"; }
                  { pattern = "\\bgit\\s+(push|clean|reset\\s+--hard)\\b"; }
                  { pattern = "\\brm\\s+-[[:alnum:]]*r[[:alnum:]]*f\\b"; }
                ];
              };
              edit_file.always_confirm = [
                { pattern = "(\\.env($|\\.)|/(\\.ssh|\\.aws|\\.gnupg)/)"; }
              ];
              write_file.always_confirm = [
                { pattern = "(\\.env($|\\.)|/(\\.ssh|\\.aws|\\.gnupg)/)"; }
              ];
            };
          };
        };

        userKeymaps = [
          {
            context = "Workspace";
            bindings = {
              "ctrl-`" = "workspace::ToggleBottomDock";
              "ctrl-shift-b" = "task::Spawn";
              "f6" = "task::Rerun";
              "f9" = "debugger::Start";
            };
          }
          {
            context = "Editor";
            bindings = {
              "f5" = [
                "task::Spawn"
                { task_name = "C++: Build & Run"; }
              ];
              "ctrl-shift-i" = "editor::Format";
            };
          }
        ];

        # Tasks globais para arquivos C/C++ isolados e para o flake.
        # Projetos com CMake devem possuir suas proprias tasks em .zed/tasks.json.
        userTasks = [
          {
            label = "C++: Build & Run";
            command = bash;
            args = [
              "-c"
              ''
                set -e
                mkdir -p "$ZED_WORKTREE_ROOT/outputs"
                g++ -std=c++23 -Wall -Wextra -Wpedantic -O2 \
                  "$ZED_FILE" -o "$ZED_WORKTREE_ROOT/outputs/$ZED_STEM"
                "$ZED_WORKTREE_ROOT/outputs/$ZED_STEM"
              ''
            ];
            cwd = "$ZED_WORKTREE_ROOT";
            save = "current";
            reveal = "always";
            hide = "never";
            allow_concurrent_runs = false;
          }
          {
            label = "C++: Build Debug";
            command = bash;
            args = [
              "-c"
              ''
                set -e
                mkdir -p "$ZED_WORKTREE_ROOT/outputs"
                g++ -std=c++23 -Wall -Wextra -Wpedantic -g -O0 \
                  "$ZED_FILE" -o "$ZED_WORKTREE_ROOT/outputs/$ZED_STEM"
              ''
            ];
            cwd = "$ZED_WORKTREE_ROOT";
            save = "current";
            reveal = "always";
          }
          {
            label = "C++: Run";
            command = bash;
            args = [
              "-c"
              ''exec "$ZED_WORKTREE_ROOT/outputs/$ZED_STEM"''
            ];
            cwd = "$ZED_WORKTREE_ROOT";
            reveal = "always";
          }
          {
            label = "Nix: Flake Check";
            command = "nix";
            args = [
              "flake"
              "check"
              "--no-build"
              "$ZED_WORKTREE_ROOT"
            ];
            cwd = "$ZED_WORKTREE_ROOT";
            reveal = "always";
          }
          {
            label = "Nix: Format File";
            command = "${pkgs.nixfmt}/bin/nixfmt";
            args = [ "$ZED_FILE" ];
            cwd = "$ZED_WORKTREE_ROOT";
            save = "current";
            reveal = "always";
          }
          {
            label = "Git: Status";
            command = "git";
            args = [
              "status"
              "--short"
            ];
            cwd = "$ZED_WORKTREE_ROOT";
            reveal = "always";
          }
          {
            label = "Git: LazyGit";
            command = "lazygit";
            cwd = "$ZED_WORKTREE_ROOT";
            reveal = "always";
          }
        ];

        # Debug de arquivos C++ isolados (compila com -g antes de executar).
        userDebug = [
          {
            label = "C++: Debug";
            adapter = "CodeLLDB";
            request = "launch";
            program = "$ZED_WORKTREE_ROOT/outputs/$ZED_STEM";
            cwd = "$ZED_WORKTREE_ROOT";
            build = "C++: Build Debug";
          }
        ];
      };
    };
}
