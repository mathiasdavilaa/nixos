
{ inputs, ... }:

{
  flake.homeModules.discord = { ... }: {
    # Nixcord:
    # https://github.com/4evy/nixcord
    # Documentação:
    # https://4evy.github.io/nixcord/

    imports = [
      inputs.nixcord.homeModules.nixcord
    ];

    programs.nixcord = {
      enable = true;

      discord = {
        enable = true;
        installPackage = true;

        vencord.enable = true;
        openASAR.enable = true;
      };

      vesktop = {
        enable = true;
        installPackage = true;
        useSystemVencord = true;
      };

      # CSS opcional.
      # Atenção: o @import depende de um site externo.
      quickCss = ''
        @import url("https://ridge.codeberg.page/Discord-Adblock/discord-adblock.css");
      '';

      config = {
        useQuickCss = true;

        # As atualizações ficam sob responsabilidade do Nix.
        autoUpdate = false;
        autoUpdateNotification = false;

        plugins = {
          # Imagens e mídia
          fixImagesQuality.enable = true;
          fixYoutubeEmbeds.enable = true;
          webScreenShareFixes.enable = true;
          biggerStreamPreview.enable = true;
          hideMedia.enable = true;

          # Voz
          disableCallIdle.enable = true;
          callTimer.enable = true;
          streamerModeOnStream.enable = true;

          volumeBooster = {
            enable = true;
            multiplier = 2.0;
          };

          # Mensagens
          shikiCodeblocks.enable = true;
          fullSearchContext.enable = true;
          voiceMessages.enable = true;
          gifPaste.enable = true;
          betterUploadButton.enable = true;

          # Privacidade e interface
          noTrack.enable = true;
          platformIndicators.enable = true;
          showHiddenChannels.enable = true;
          showConnections.enable = true;
          consoleJanitor.enable = true;
          translate.enable = true;

          # Remove avisos de links e arquivos suspeitos.
          # Menos seguro: habilite somente se desejar.
          # alwaysTrust.enable = true;

          fakeNitro = {
            enable = true;

            enableEmojiBypass = true;
            emojiSize = 48;
            transformEmojis = true;

            enableStickerBypass = true;
            stickerSize = 160;
            transformStickers = true;
            transformCompoundSentence = false;

            enableStreamQualityBypass = true;

            useHyperLinks = true;
            hyperLinkText = "{{NAME}}";

            disableEmbedPermissionCheck = false;
          };

          ignoreActivities = {
            enable = true;
            ignorePlaying = true;
            ignoreStreaming = true;
            ignoreWatching = true;
            ignoreListening = true;
            ignoreCompeting = true;
          };
        };
      };
    };
  };
}
