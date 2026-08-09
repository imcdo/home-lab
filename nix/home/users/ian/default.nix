{ pkgs, lib, sshConfig, homeDirectory ? "/home/ian", username ? "ian", ... }:

{
  programs.home-manager.enable = true;

  home = {
    username = username;
    homeDirectory = homeDirectory;
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
      wget
      fluxcd
      python3
      cloudflared
      btop
      etcd
      screen
      python313Packages.uptime
    ]
    ++ lib.optionals pkgs.stdenv.isLinux (with pkgs; [
      docker
      iptables
      unixtools.ping
      unixtools.netstat
    ])
    ++ (with pkgs.python313Packages; [
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
      update = if pkgs.stdenv.isDarwin then "sudo darwin-rebuild switch" else "sudo nixos-rebuild switch";
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
