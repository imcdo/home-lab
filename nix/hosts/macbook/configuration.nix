{ config, lib, pkgs, ... }:

{
  networking.hostName = "macbook";
  networking.computerName = "macbook";
  networking.localHostName = "macbook";

  time.timeZone = "America/Los_Angeles";

  # Determinate Nix manages the local Nix installation; keep nix-darwin from
  # trying to re-install/manage it during activation.
  nix.enable = false;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = 5;

  programs.zsh.enable = true;

  users.users.ian = {
    home = "/Users/ian";
    shell = pkgs.zsh;
  };

  nixpkgs.config.allowUnfreePredicate = pkg:
    let
      name = lib.getName pkg;
    in
      builtins.elem name [
        "vscode"
        "vscode-extension-ms-python-python"
        "vscode-extension-MS-python-vscode-pylance"
      ]
      || lib.hasPrefix "vscode-extension-ms-dotnettools-" name;

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    tmux
  ];

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };

    brews = [
      "helm"
    ];

    # Fallback for GUI apps that are better managed as macOS casks.
    casks = [
      "discord"
      "godot"
      "lastpass"
    ];
  };
}