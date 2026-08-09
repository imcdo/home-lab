{ pkgs, ... }:

{
  # Shared Home Manager config for personal machines (macOS + WSL).
  home.packages = with pkgs; [
    alejandra
    nil
  ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    mutableExtensionsDir = true;

    userSettings = {
      "editor.formatOnSave" = true;
      "editor.minimap.enabled" = false;
      "files.trimTrailingWhitespace" = true;
      "files.insertFinalNewline" = true;
      "terminal.integrated.defaultProfile.linux" = "zsh";
      "terminal.integrated.defaultProfile.osx" = "zsh";
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nil";
      "nix.serverSettings.nil.formatting.command" = [ "alejandra" ];
    };
  };
}
