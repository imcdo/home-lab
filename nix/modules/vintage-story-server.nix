{ config, pkgs, pkgs-unstable, lib, ... }:

with lib;

let
  cfg = config.services.homelab.vintageStory;
  user = "vintage-story";
  group = "vintage-story";
  homeDir = "/home/${user}";
  dataDir = "${homeDir}/data";
  serverConfigFile = pkgs.writeText "serverconfig.json" (builtins.toJSON (recursiveUpdate {
      ServerName = "NixOS Vintage World";
      Port = cfg.port;
      Password = cfg.password;
      VerifyPlayerAuth = true;
      # Required to point to the internal data folder
      DataPath = dataDir; 
    } cfg.extraSettings));

    # 2. Generate the Users/Admins JSON
    # This maps your Nix list of admins into the format Vintage Story expects.
    usersFile = pkgs.writeText "users.json" (builtins.toJSON (map (admin: {
      Uid = admin.uid;
      Name = admin.name;
      RoleCode = "admin";
      # These are boilerplate requirements for the JSON schema
      TenantId = "default";
      AclState = 0;
    }) cfg.admins));
in {
  options.services.homelab.vintageStory = {
    enable = mkEnableOption "Vintage Story Server";

    port = mkOption { type = types.port; default = 42420; };
    password = mkOption { type = types.nullOr types.str; default = null; };

    # The "Nix Way" Admin List
    admins = mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption { type = types.str; description = "Player username"; };
          uid = mkOption { type = types.str; description = "The player's Vintage Story UID"; };
        };
      });
      default = [];
    };

    extraSettings = mkOption {
      type = types.attrs;
      default = {};
      description = "Any other serverconfig.json keys you want to override";
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true;

    networking.firewall.allowedTCPPorts = [ cfg.port ];
    networking.firewall.allowedUDPPorts = [ cfg.port ];

    users.groups.${group} = {};
    users.users.${user} = {
      group = group;
      isSystemUser = true;
      home = homeDir;
      createHome = true;
      shell = pkgs.bash;
    };

    systemd.services.vintage-story = {
      description = "Vintage Story Dedicated Server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        User = user;
        Group = group;
        WorkingDirectory = homeDir;
        # Use the binary from the Nix package
        ExecStart = "${pkgs.vintagestory}/bin/vintagestory-server --dataPath ${dataDir}";
        Restart = "always";
      };

      preStart = ''
        mkdir -p ${dataDir}
        
        # Copy the Nix-generated configs into the data directory
        # We use 'cp' instead of 'ln' because the server occasionally 
        # likes to write updates to these files.
        cp -f ${serverConfigFile} ${dataDir}/serverconfig.json
        cp -f ${usersFile} ${dataDir}/users.json
        
        chown -R ${user}:${group} ${dataDir}
        chmod 600 ${dataDir}/*.json
      '';
    };
  };
}