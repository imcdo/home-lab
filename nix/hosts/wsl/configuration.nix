{ config, lib, pkgs, ... }:

let
  hostName = "wsl";
  wslNixosRebuild = pkgs.writeShellScriptBin "wsl-nixos-rebuild" ''
    exec sudo nixos-rebuild switch --flake /home/ian/home-lab/nix#wsl "$@"
  '';
  wslKubeconfig = pkgs.writeShellScriptBin "wsl-kubeconfig" ''
    #!/usr/bin/env bash
    set -euo pipefail

    k3s_host="''${1:-think}"
    target="''${2:-$HOME/.kube/config}"

    mkdir -p "$(dirname "$target")"

    ssh "ian@''${k3s_host}" "sudo cat /etc/rancher/k3s/k3s.yaml" \
      | sed "s#127.0.0.1#''${k3s_host}#g" \
      > "$target"

    chmod 600 "$target"
    echo "kubeconfig written to $target"
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
    wslKubeconfig
  ];

  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.11";
}
