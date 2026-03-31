{ pkgs, lib, sshConfig, ... }:

{
  programs.home-manager.enable = true;

  home = {
    username = "ian";
    homeDirectory = "/home/ian";
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
      k9s
      kubectl
      helm
      docker
      wget
      fluxcd
      python3
      cloudflared
      btop
      iptables
      etcd
      unixtools.ping
      unixtools.netstat
      python313Packages.uptime
    ]  ++ (with pkgs.python313Packages; [
      pip
      virtualenv
      pipx
      requests
    ]);
    sessionVariables = {
      EDITOR = "nvim";
    };
  };


  # Basic shell configuration
  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "ls -la";
      k = "kubectl";
      update = "sudo nixos-rebuild switch";
    };
    history.size = 10000000;

    oh-my-zsh = { # "ohMyZsh" without Home Manager
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
