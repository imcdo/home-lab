{ pkgs, lib, ... }:

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
    extensions =
      (with pkgs.vscode-extensions; [
      # Nix
      bbenoist.nix
      jnoortheen.nix-ide

      # Python
      ms-python.python
      ms-python.vscode-pylance

      # C / C++
      ms-vscode.cpptools
      ms-vscode.cmake-tools
      twxs.cmake

      # C#
      ms-dotnettools.csharp
      ms-dotnettools.csdevkit

      # General quality-of-life
      editorconfig.editorconfig
      redhat.vscode-yaml
      ])
      ++ lib.optionals (pkgs.vscode-extensions ? geequlim && pkgs.vscode-extensions.geequlim ? "godot-tools") [
        pkgs.vscode-extensions.geequlim."godot-tools"
      ];

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
