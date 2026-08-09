{ config, lib, pkgs, ... }:

{
  networking.hostName = "macbook";
  networking.computerName = "macbook";
  networking.localHostName = "macbook";

  time.timeZone = "America/Los_Angeles";

  nix.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.zsh.enable = true;

  users.users.ian = {
    home = "/Users/ian";
    shell = pkgs.zsh;
  };

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

    # Fallback for GUI apps that are better managed as macOS casks.
    casks = [
      "discord"
      "font-fira-code"
      "godot"
    ];
  };
}