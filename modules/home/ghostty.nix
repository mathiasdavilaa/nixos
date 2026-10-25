{
  flake.homeModules.ghostty = { ... }: {
    programs.ghostty = {
      enable = true;
      package = null;
      systemd.enable = false;

      settings = {
        confirm-close-surface = false;
        font-family = "GeistMono Nerd Font";
        cursor-style = "block";
        window-padding-x = 8;
        window-padding-y = 8;
        shell-integration = "detect";
        shell-integration-features = "no-cursor,sudo,title,ssh-env,ssh-terminfo";
        #custom-shader = "${../../assets/ghostty/cursor-trail.glsl}";
        custom-shader-animation = true;
        scrollback-limit = 32 * 1024 * 1024;
        copy-on-select = "clipboard";
        clipboard-paste-protection = true;
        window-inherit-working-directory = true;
      };
    };
  };
}
