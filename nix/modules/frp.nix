{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.homelab.frp;
  user = "frp";
  group = "frp";
in {
  options.services.homelab.frp = {
    enable = mkEnableOption "Enable FRP client for remote access";

    serverAddr = mkOption {
      type = types.str;
      default = "frp1.exfrp.com";
      description = "FRP server address";
    };

    serverPort = mkOption {
      type = types.port;
      default = 7000;
      description = "FRP server port";
    };

    tokenFile = mkOption {
      type = types.path;
      description = "Path to file containing the FRP authentication token";
    };

    services = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          type = mkOption {
            type = types.enum [ "tcp" "udp" ];
            description = "Service type (tcp or udp)";
          };
          localIp = mkOption {
            type = types.str;
            default = "127.0.0.1";
            description = "Local IP address to forward from";
          };
          localPort = mkOption {
            type = types.port;
            description = "Local port to forward from";
          };
          remotePort = mkOption {
            type = types.port;
            description = "Remote port to expose on FRP server";
          };
        };
      });
      default = {};
      description = "Services to expose through FRP";
    };
  };

  config = mkIf cfg.enable {
    # Create FRP user and group
    users.groups.${group} = {};
    users.users.${user} = {
      group = group;
      isSystemUser = true;
      description = "FRP service user";
      shell = pkgs.bash;
    };

    # Configure FRP service
    services.frp = {
      enable = true;
      role = "client";
      settings = 
        {
          common = {
            server_addr = cfg.serverAddr;
            server_port = cfg.serverPort;
            token_file = cfg.tokenFile;
          };
        } // cfg.services;
    };

    # Ensure FRP service runs as the correct user
    systemd.services.frp = {
      serviceConfig = {
        User = user;
        Group = group;
        # Add supplementary groups to access secrets
        SupplementaryGroups = [ "keys" ];
      };
    };
  };
}