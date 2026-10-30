{ ... }:
{
  flake.homeModules.obsidian =
    { lib, pkgs, ... }:
    let
      # Instala os arquivos das releases; manifestId evita ler a derivação na avaliação.
      mkPlugin =
        {
          id,
          repo,
          version,
          hashes,
        }:
        let
          files = lib.mapAttrs (
            name: hash:
            pkgs.fetchurl {
              name = "${id}-${name}";
              url = "https://github.com/${repo}/releases/download/${version}/${name}";
              inherit hash;
            }
          ) hashes;
        in
        pkgs.runCommand "obsidian-${id}-${version}"
          {
            passthru.manifestId = id;
          }
          ''
            mkdir -p "$out"
            ${lib.concatStringsSep "\n" (
              lib.mapAttrsToList (name: file: ''
                cp ${file} "$out/${name}"
              '') files
            )}
          '';

      # Versões e hashes fixos. Atualize os dois juntos para atualizar um plugin.
      plugins = [
        (mkPlugin {
          id = "obsidian-linter";
          repo = "platers/obsidian-linter";
          version = "1.34.2";
          hashes = {
            "main.js" = "sha256-ova0R27tYWq6ZOlT6t2ut58h16jbB1nrsHD70CgUIYs=";
            "manifest.json" = "sha256-4Cpa3FPccf7ewVhBNfvToCS1aYQ0y79socu5sSnuduA=";
            "styles.css" = "sha256-rto6ZoBw3h5IZQ0WE6lr0Bjgt7OqX6vchSY1ifEZhjQ=";
          };
        })
        (mkPlugin {
          id = "table-editor-obsidian";
          repo = "tgrosinger/advanced-tables-obsidian";
          version = "0.23.2";
          hashes = {
            "main.js" = "sha256-z13U3b3evvaMyZzZOog+M4lcfxI9BLxdEQbqbjOLp5E=";
            "manifest.json" = "sha256-aYtPd0ReB9iH8zRQ6vUzoo4Jm3tIP2QvqIM2L/vY/+k=";
            "styles.css" = "sha256-I/ow128Rf9PRYkxMLm3e2r+AmSOZawU0iV+CVOpqOfc=";
          };
        })
        (mkPlugin {
          id = "obsidian-spaced-repetition";
          repo = "st3v3nmw/obsidian-spaced-repetition";
          version = "1.15.4";
          hashes = {
            "main.js" = "sha256-4q8aNHetVL8GPuh4ekZWYc9nJdiDlOny8V544LwpmTs=";
            "manifest.json" = "sha256-a0v3glbNDviBb6LPTwAkjAGxgGb45p/ulp1Io3kbzWU=";
            "styles.css" = "sha256-xirl+rVH102ERuBaogy1Xv67+nzQ4HQ8lR3MK3e0mr0=";
          };
        })
        (mkPlugin {
          id = "obsidian-latex-suite";
          repo = "artisticat1/obsidian-latex-suite";
          version = "1.14.1";
          hashes = {
            "main.js" = "sha256-JJ2LDqyXbjufqFGLaPRI153wengANjYvUU5mzqn+PUs=";
            "manifest.json" = "sha256-MgGo1dKgGFnaza+YXW1WVFiAo4+ZnCFH5d8u2wpGk2U=";
            "styles.css" = "sha256-ouLvTepHnpwjd/CpiD/lOfwrEpskSGNCQwn4+SwdyBQ=";
          };
        })
      ];
    in
    {
      programs.obsidian = {
        enable = true;
        defaultSettings = {
          app = {
            defaultViewMode = "source";
            livePreview = true;
            readableLineLength = true;
            showLineNumber = true;
            showInlineTitle = false;
            spellcheck = true;
            tabSize = 2;
            useTab = false;

            useMarkdownLinks = true;
            newLinkFormat = "relative";
            strictLineBreaks = true;
            alwaysUpdateLinks = true;

          };

          appearance.baseFontSize = 17;
          cssSnippets = [
            {
              name = "study";
              text = ''
                /* Ajustes de leitura que acompanham as cores do tema escolhido. */
                .markdown-source-view.mod-cm6,
                .markdown-preview-view {
                  --file-line-width: 80ch;
                  --line-height-normal: 1.65;
                  --line-height-tight: 1.35;
                  --p-spacing: 0.9rem;
                  --heading-spacing: 1.4em;
                }

                .markdown-source-view.mod-cm6 .cm-inline-code,
                .markdown-preview-view :not(pre) > code {
                  font-size: 0.92em;
                }
              '';
            }
          ];

          # Lista completa: plugins nativos omitidos ficam desativados.
          corePlugins = [
            "file-explorer"
            "global-search"
            "switcher"
            "command-palette"
            "backlink"
            "outgoing-link"
            "outline"
            "page-preview"
            "properties"
            "tag-pane"
            "bookmarks"
            "note-composer"
            "editor-status"
            "word-count"
            "file-recovery"
            "canvas"
            "graph"
            "bases"
            "workspaces"
            "sync"
            "templates"
            "daily-notes"
          ];

          communityPlugins = plugins;

          # Os data.json dos plugins ficam editáveis. O Spaced Repetition
          # precisa gravar seu estado durante o uso.

          hotkeys."templates:insert-template" = [
            {
              modifiers = [
                "Mod"
                "Shift"
              ];
              key = "T";
            }
          ];
        };
      };
    };
}
