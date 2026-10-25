# AppImage oficial do Liner, com versão e hash fixados.
# Usamos appimage-run para evitar a colisão de links do buildFHSEnv
# observada com appimageTools.wrapType2 nesta configuração.
{ pkgs, lib, fetchurl, ... }:
let
  version = "0.2.10";

  src = fetchurl {
    url = "https://github.com/tryliner/desktop/releases/download/v${version}/Liner-${version}.AppImage";
    hash = "sha256-T68a39RS0gcINjh/WpCBBUqLs+sQkYQWW4v3DelswC4=";
  };

  launcher = pkgs.writeShellScriptBin "liner" ''
    exec ${lib.getExe pkgs.appimage-run} ${src} "$@"
  '';

  desktop = pkgs.makeDesktopItem {
    name = "liner";
    desktopName = "Liner";
    comment = "Reprodutor de música";
    exec = "liner";
    icon = "multimedia-player";
    categories = [ "Audio" "Music" "Player" ];
  };
in
pkgs.symlinkJoin {
  name = "liner-${version}";
  paths = [ launcher desktop ];

  meta = {
    description = "Liner desktop music player (AppImage)";
    homepage = "https://github.com/tryliner/desktop";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "liner";
  };
}
