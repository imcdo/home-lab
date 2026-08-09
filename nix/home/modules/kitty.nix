{ ... }:

{
  programs.kitty = {
    enable = true;

    settings = {
      background = "#1b1d2b";
      foreground = "#f8f8f2";
      selection_background = "#44475a";
      selection_foreground = "#f8f8f2";
      color0 = "#21222c";
      color1 = "#ff5555";
      color2 = "#50fa7b";
      color3 = "#f1fa8c";
      color4 = "#bd93f9";
      color5 = "#ff79c6";
      color6 = "#8be9fd";
      color7 = "#f8f8f2";
      color8 = "#6272a4";
      color9 = "#ff6e6e";
      color10 = "#69ff94";
      color11 = "#ffffa5";
      color12 = "#d6acff";
      color13 = "#ff92df";
      color14 = "#a4ffff";
      color15 = "#ffffff";
      confirm_os_window_close = 0;
      cursor_shape = "block";
      enable_audio_bell = false;
      font_family = "Fira Code";
      macos_option_as_alt = true;
      scrollback_lines = 10000;
      tab_bar_edge = "top";
      tab_bar_style = "powerline";
    };

    keybindings = {
      "ctrl+shift+enter" = "new_window";
      "ctrl+shift+t" = "new_tab";
      "ctrl+shift+w" = "close_window";
    };
  };
}
