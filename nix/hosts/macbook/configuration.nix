{
  config,
  lib,
  pkgs,
  ...
}: {
  networking.hostName = "macbook";
  networking.computerName = "macbook";
  networking.localHostName = "macbook";

  time.timeZone = "America/Los_Angeles";

  # Determinate Nix manages the local Nix installation; keep nix-darwin from
  # trying to re-install/manage it during activation.
  nix.enable = false;
  nix.settings.experimental-features = ["nix-command" "flakes"];
  system.stateVersion = 5;

  programs.zsh.enable = true;

  # Manage sleep behavior with pmset.
  # - On AC: keep system awake for docked/lid-closed operation.
  # - On battery: allow normal sleep to preserve battery life.
  system.activationScripts.disableSleepOnAC.text = ''
    # AC power profile
    /usr/bin/pmset -c disablesleep 1
    /usr/bin/pmset -c sleep 0
    /usr/bin/pmset -c displaysleep 15
    /usr/bin/pmset -c disksleep 10
    /usr/bin/pmset -c lidwake 1

    # Battery profile
    /usr/bin/pmset -b disablesleep 0
    /usr/bin/pmset -b sleep 15
    /usr/bin/pmset -b displaysleep 5
    /usr/bin/pmset -b disksleep 10
    /usr/bin/pmset -b lidwake 1
  '';

  users.users.ian = {
    home = "/Users/ian";
    shell = pkgs.zsh;
  };

  nixpkgs.config.allowUnfreePredicate = pkg: let
    name = lib.getName pkg;
  in
    builtins.elem name [
      "vscode"
      "vscode-extension-ms-python-python"
      "vscode-extension-MS-python-vscode-pylance"
      "spotify"
      "gitlab-runner"
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
