{
  pkgs,
  lib,
  sshConfig,
  ...
}: {
  programs.home-manager.enable = true;

  home = {
    username = "remote";
    homeDirectory = "/Users/remote";
    stateVersion = "23.11";

    file.".ssh/authorized_keys" = {
      text = ''
        ${sshConfig.defaultPublicKey}
      '';
    };

    packages = with pkgs; [
      ripgrep
      fd
      tmux
      bat
      neovim
      git
      curl
      wget
      jq
      tree
      btop
      python3
    ] ++ lib.optionals pkgs.stdenv.isDarwin [
        godot
    ]; 

    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    mutableExtensionsDir = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
        jnoortheen.nix-ide
        ms-python.python
        ms-python.vscode-pylance
        editorconfig.editorconfig
        redhat.vscode-yaml
      ];
      userSettings = {
        "editor.formatOnSave" = true;
        "editor.minimap.enabled" = false;
        "files.trimTrailingWhitespace" = true;
        "files.insertFinalNewline" = true;
        "terminal.integrated.defaultProfile.osx" = "zsh";
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nil";
        "nix.serverSettings.nil.formatting.command" = ["alejandra"];
      };
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.git = {
    enable = true;
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "ls -la";
      k = "kubectl";
    };
    history.size = 10000000;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "kubectl"
        "ssh"
        "emoji"
        "autojump"
        "helm"
      ];
      theme = "simple";
    };
  };
}
