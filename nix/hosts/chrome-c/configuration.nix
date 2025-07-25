# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];
  # Use the systemd-boot EFI boot loader.
  # boot.loader.efi.canTouchEfiVariables = true;
  # boot.loader.grub.device = "nodev";
  # boot.loader.grub.efiSupport = true;
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
    };
    systemd-boot = {
      enable = true;
      configurationLimit = 100;
    };
  };
  # Pick only one of the below networking options.
  networking.wireless = {
    enable = true;
    userControlled.enable = true;
    networks = {
      "The Pirate Ping" = {
        psk = "thegumgumfruit";
      };
    };
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";
  services = {
    xserver = {
      xkb.layout = "us";
    };

    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
        PubkeyAuthentication = true;
      };
    };
  };

  # Homelab modules configuration
  services.homelab = {
    # K3s cluster configuration
    k3s = {
      enable = true;
      role = "server";
      clusterInit = false;
      serverAddr = "https://192.168.0.95:6443"; # IP of the think server node
    };

    # Users configuration
    users = {
      enable = true;
      mainUser.enable = true;
      nixAdmin.enable = true;
      nixPermissions.enable = true;
    };
  };


  # Set hostname
  networking.hostName = "chrome-c";

  # Packages now handled by homelab modules
  environment.systemPackages = with pkgs; [
    vim # Editor
    wget
    git # Required for GitOps workflows
  ];

  # Networking hostname is now handled by the k3s module
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05";

  # Enable experimental Nix features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
