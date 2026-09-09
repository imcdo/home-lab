{
  pkgs,
  lib,
  sshConfig,
  homeDirectory ? "/home/ian",
  username ? "ian",
  ...
}: let
  darwinRebuildWrapper = pkgs.writeShellScriptBin "darwin-rebuild" ''
    exec nix run github:LnL7/nix-darwin/nix-darwin-24.11\#darwin-rebuild -- "$@"
  '';
in {
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
        wget
        fluxcd
        python3
        cloudflared
        btop
        etcd
        screen
        opencode
        opencode-desktop
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
    enable = true;
    settings = {
      user.name = "imcdo";
      user.email = "ian_mcdonald@rocketmail.com";
      core.editor = "vim";
      pull.rebase = "true";
      url."git@github.com:".insteadOf = "https://github.com/";
    };
  };

  # Basic shell configuration
  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "ls -la";
      k = "kubectl";
      update =
        if pkgs.stdenv.isDarwin
        then "nix run github:LnL7/nix-darwin/nix-darwin-24.11\#darwin-rebuild -- switch --flake $HOME/git/home-lab/nix\#macbook"
        else "sudo nixos-rebuild switch";
    };
    history.size = 10000000;

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
