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
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.device = "/dev/sda";
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
    };
  };
  users.groups.k3s = { };
  users.groups.nix = { };
  users.groups.nix-admins = { };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users.users.ian = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "nix"
      "nix-admins"
      "k3s"
      "docker"
    ];
    description = "Ian";
    shell = pkgs.bash;
    home = "/home/ian";
    packages = with pkgs; [
      nodejs-slim_24
    ];
  };

  users.users.nixadmin = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "nix"
      "k3s"
      "docker"
    ];
    description = "Nix Admin";
    shell = pkgs.bash;
    home = "/home/nixadmin";
  };

  users.users.k3s = {
    isSystemUser = true;
    group = "k3s";
    home = "/var/lib/rancher/k3s";
    createHome = true;
    description = "K3s System User";
    shell = "/sbin/nologin";
  };

  system.activationScripts.fixNixosPermissions.text = ''
    chown -R root:nixos-admins /etc/nixos
    chmod -R g+rwX /etc/nixos
  '';

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
  ];
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22 # SSH
    6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
    2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
    2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
  ];
  networking.firewall.allowedUDPPorts = [
    8472 # k3s, flannel: required if using multi-node for inter-node networking
  ];

  services.k3s = { 
    enable = true;
    role = "server";
    token = "iansk3sclustertoken";
    clusterInit = true;

  };
  networking.hostName = "think";
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
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05";

}
