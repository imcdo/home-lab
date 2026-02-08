{ pkgs, lib, sshConfig, ... }:

{
  home.username = "ian";
  home.stateVersion = "23.11"; 
  programs.home-manager.enable = true;

  # Basic shell configuration
  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "ls -la";
      update = "sudo nixos-rebuild switch";
    };
    history.size = 10000000;

    oh-my-zsh = { # "ohMyZsh" without Home Manager
      enable = true;
      plugins = [
        "git"
      ];
      theme = "simple";
    };
  };

  # Install packages for your user
  home.packages = with pkgs; [
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

  home.file.".ssh/authorized_keys" = {
    text = ''
      ${sshConfig.defaultPublicKey}
    '';
  };
}
