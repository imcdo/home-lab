{ pkgs, lib, sshConfig, homeDirectory ? "/home/ian", username ? "ian", ... }:

let
  darwinRebuildWrapper = pkgs.writeShellScriptBin "darwin-rebuild" ''
    exec nix run github:LnL7/nix-darwin/nix-darwin-24.11\#darwin-rebuild -- "$@"
  '';
in

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
      update = if pkgs.stdenv.isDarwin then "nix run github:LnL7/nix-darwin/nix-darwin-24.11\#darwin-rebuild -- switch --flake $HOME/git/home-lab/nix\#macbook" else "sudo nixos-rebuild switch";
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
