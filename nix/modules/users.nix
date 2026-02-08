{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.homelab.users;
  christianSshPublicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCgGX3jzujNs6a192SuIC75KUOsyGfTN6elM2CXtcuimnqxOOa19Ect6RMb9OVdNi4BkzIHvYrES9WJDFqYpaDzpX6yYmBeg47aKps+n16+Y1PPqU9DkJDNBbqXHb3YsHFX6jq+Dc7ledUy64hyrQuhID/jajSC7ZSOiFLfzpX7yjWMXjgciyIfDgmi68ZAyzHUODN1/Ab5fV6HLTiNSJbTzMoVyvb9f86uCTdbCYEEk0pLCoRZoUaBMD+hvXu0NM8nclXT1bWe7nVSijaLeBOLAG8SGEun7LxN7jbVFmHtUDg/rT33ACmZHVHLNu6P47oJ4YyILuXzK7wWCZVb7vU4lP9HBbfgWCNRtiNokGzyi2Y5amGWqWvxPEKSRTXSTXie18XyjehFkLuKCjvLOykYGSQA7NM3mEDqBeiaKyB9Sl4kF9gEOWZ24mHQqIxbMFWY60IdnPqpF1KLy1oVg0KnxmC2LCbd4GSMm2vzgEPNM+F/nfVW4CcnLqiI1AmW3q9GX4BYDX9KcRYaqrzA2sNGlvCAnpr6XVP2OBBcTJCHCs4S3unUMiRlN7m1xWgAP2DNqjy5MObgau8JDjvV8Xcv7fLwDTKxPJTzZGGPazQq3brIbXGKhkQNXdghVe7Ld8OV5uzyEUQQoUiYER2Hh5ATukNkM3qvpAtjaGZcsHPt9Q== christian@grandlan.dev";
in
{
  options.services.homelab.users = {
    enable = mkEnableOption "Enable homelab user configuration";

    sshKey = mkOption {
      type = types.str;
      default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDJwCoP+9JDU6mH4pZCsk/GlhDXiarbdyaakIB1DzLMRtiv79U/aTkTvgm/TTmeQLM0W3vHYsKDloNRhRK87UbN798aiYk1g6w51OL7ClxlGStpZoRtTAA+enG2g55Vhx7WUM0kKvYw44iSWH60NN+XCItdHrGB6hBNf9Q86h+fzv2U92PvZOEjdX2PaNZ/2RR3QA6kf1ra8Na5RdXu3wvAZx+qAzrPXP8TGShcMc1kdYFC/RPzkUrj0Y2il3LXO7gAo1fi+RyZi9y0vvK3YNDHqxVE+dmMNYz9Ipsy2QBHF7vowJajvJVEAn8DQDSeQqRWwVeQZPTywzZbG8Ng0HlNV1QjUQbh3ZB3lWUdu5RQqD+Tltzo6fWkkN49FiYse/zlrIiUSayvALcGxeyvKTa0udIO2mGZO94aY/pg5uhG4/dHNk3JWRI2QyE0RyxCBRn9YksMPXVgkQ/ARgIbqrNP22JLFeffeB+zfBQQiPGsfnqTr8RWTyzlkltom6Uh5dksn7WfnbTofQbMIw6bU9x15+tmoxgJm3QzTnandpVXOsxSx5M2NJyTYIvkKegbJcRS0C4AiUeLDhm4feN/fg6oSRV4m+qpeFug0bO0AqjjKaaYOMHS6FoyT0osoLECMg0NjFdSuOVAdp7eB3sZD3nTtTPsnayyj+3uip+ajNhahw== ian@DESKTOP-C07E16P";
      description = "SSH public key for homelab users";
    };

    mainUser = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable the main homelab user (ian)";
      };

      packages = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [
          wget
          fluxcd
          kubectl
          k9s
          python
          btop
          iptables
          etcd
          dig
          tmux
          unixtools.nettools
          unixtools.ping
          unixtools.netstat
          python313Packages.uptime
        ] ++ (with pkgs.python313Packages; [
          pip
          virtualenv
          pipx
          requests
        ]);
        description = "Additional packages for the main user";
      };
    };

    nixAdmin = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable the nixadmin user";
      };
    };

    nixPermissions = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable NixOS configuration permissions setup";
      };
    };
  };

  config = mkIf cfg.enable {
    # Create groups
    users.groups = {
      k3s = {};
      nix = {};
      nix-admins = {};
    };

    # Root user configuration
    users.users.root = {
      openssh.authorizedKeys.keys = [ cfg.sshKey ];
    };

    # Main user (admin)
    users.users."ian" = mkIf cfg.mainUser.enable {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "nix"
        "nix-admins"
        "k3s"
        "docker"
      ];
      description = "Administrator";
      shell = pkgs.bash;
      home = "/home/ian";
      packages = cfg.mainUser.packages;
      openssh.authorizedKeys.keys = [ cfg.sshKey ];
    };

    users.users.christian =  {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "nix"
        "nix-admins"
        "k3s"
        "docker"
      ];
      description = "Christian";
      shell = pkgs.bash;
      home = "/home/christian";
      packages = cfg.mainUser.packages;
      openssh.authorizedKeys.keys = [ christianSshPublicKey ];
    };

    # Admin user
    users.users.nixadmin = mkIf cfg.nixAdmin.enable {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "nix"
        "nix-admins"
        "k3s"
        "docker"
      ];
      description = "Nix Admin";
      shell = pkgs.bash;
      home = "/home/nixadmin";
    };

    # Sudo configuration
    security.sudo.extraRules = [
      {
        users = [ "ian" ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];

    # NixOS permissions setup
    system.activationScripts.fixNixosPermissions = mkIf cfg.nixPermissions.enable {
      text = ''
        chown -R root:nix-admins /etc/nixos
        chmod -R g+rwX /etc/nixos
      '';
    };


  };
}
