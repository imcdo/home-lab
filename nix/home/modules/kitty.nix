{ ... }:

{
  programs.kitty = {
    enable = true;

    settings = {
      background = "#120b2f";
      foreground = "#f5eaff";
      selection_background = "#3a2f73";
      selection_foreground = "#fef6ff";
      color0 = "#1a123d";
      color1 = "#ff4d9e";
      color2 = "#7dffda";
      color3 = "#ffd166";
      color4 = "#7aa2ff";
      color5 = "#ff71ce";
      color6 = "#55e6ff";
      color7 = "#f2ecff";
      color8 = "#4c3c82";
      color9 = "#ff78b7";
      color10 = "#9dffd9";
      color11 = "#ffe29a";
      color12 = "#9ab8ff";
      color13 = "#ff9fe0";
      color14 = "#8cf4ff";
      color15 = "#ffffff";
      cursor = "#55e6ff";
      cursor_text_color = "#120b2f";
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
