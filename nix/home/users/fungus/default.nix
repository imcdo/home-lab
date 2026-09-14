{
  pkgs,
  lib,
  sshConfig,
  homeDirectory ? "/home/fungus",
  username ? "fungus",
  ...
}: let
  fungusSshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDzpXXTMvAHsjA462PYq+S8krCnvuauh5CIS0IHA+RcK fungus@fungus-pc";
in {
  programs.home-manager.enable = true;

  home = {
    username = username;
    homeDirectory = homeDirectory;
    stateVersion = "23.11";

    file.".ssh/authorized_keys" = {
      text = ''
        ${fungusSshPublicKey}
      '';
    };

    packages = with pkgs;
      [
        autojump
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
        k9s
        kubectl
        python3
        btop
        etcd
        screen
        file
        python313Packages.uptime
        foot.terminfo
      ]
      ++ lib.optionals pkgs.stdenv.isLinux (with pkgs; [
        helm
        docker
        iptables
        unixtools.ping
        unixtools.netstat
      ])
      ++ lib.optionals pkgs.stdenv.isDarwin [
        darwinRebuildWrapper
      ]
      ++ (with pkgs.python313Packages; [
        uv
        requests
      ]);
    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.git = {
    enable = false;
  };

  # Basic shell configuration
  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "ls -la";
      k = "kubectl";
    };
    history = {
      size = 10000000;
    };
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "ssh"
        "emoji"
        "autojump"
        "fluxcd"
        "helm"
        "kubectl"
        "kubectx"
        "pip"
      ];
      theme = "simple";
    };
  };
}
