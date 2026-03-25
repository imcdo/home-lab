{ config, lib, pkgs, ... }:

let
  hostName = "wsl";
  wslNixosRebuild = pkgs.writeShellScriptBin "wsl-nixos-rebuild" ''
    exec sudo nixos-rebuild switch --flake /home/ian/home-lab/nix#wsl "$@"
  '';
in {
  wsl = {
    enable = true;
    defaultUser = "ian";
    wslConf.network.generateHosts = false;
  };

  networking.hostName = hostName;
  time.timeZone = "America/Los_Angeles";

  services.homelab = {
    users = {
      enable = true;
      mainUser.enable = true;
      nixAdmin.enable = false;
      nixPermissions.enable = false;
    };
  };

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [];

  environment.systemPackages = with pkgs; [
    vim
    wget
    nmap
    git
    wslNixosRebuild
  ];

  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.11";
}
