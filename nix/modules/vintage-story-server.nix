{ config, pkgs, pkgs-unstable, lib, ... }:

with lib;

let
  cfg = config.services.homelab.vintageStory;
  user = "vintage-story";
  group = "vintage-story";
  homeDir = "/home/${user}";
  dataDir = "${homeDir}/data";
  christianSshPublicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCgGX3jzujNs6a192SuIC75KUOsyGfTN6elM2CXtcuimnqxOOa19Ect6RMb9OVdNi4BkzIHvYrES9WJDFqYpaDzpX6yYmBeg47aKps+n16+Y1PPqU9DkJDNBbqXHb3YsHFX6jq+Dc7ledUy64hyrQuhID/jajSC7ZSOiFLfzpX7yjWMXjgciyIfDgmi68ZAyzHUODN1/Ab5fV6HLTiNSJbTzMoVyvb9f86uCTdbCYEEk0pLCoRZoUaBMD+hvXu0NM8nclXT1bWe7nVSijaLeBOLAG8SGEun7LxN7jbVFmHtUDg/rT33ACmZHVHLNu6P47oJ4YyILuXzK7wWCZVb7vU4lP9HBbfgWCNRtiNokGzyi2Y5amGWqWvxPEKSRTXSTXie18XyjehFkLuKCjvLOykYGSQA7NM3mEDqBeiaKyB9Sl4kF9gEOWZ24mHQqIxbMFWY60IdnPqpF1KLy1oVg0KnxmC2LCbd4GSMm2vzgEPNM+F/nfVW4CcnLqiI1AmW3q9GX4BYDX9KcRYaqrzA2sNGlvCAnpr6XVP2OBBcTJCHCs4S3unUMiRlN7m1xWgAP2DNqjy5MObgau8JDjvV8Xcv7fLwDTKxPJTzZGGPazQq3brIbXGKhkQNXdghVe7Ld8OV5uzyEUQQoUiYER2Hh5ATukNkM3qvpAtjaGZcsHPt9Q== christian@grandlan.dev";
  ianSshPublicKey ="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDJwCoP+9JDU6mH4pZCsk/GlhDXiarbdyaakIB1DzLMRtiv79U/aTkTvgm/TTmeQLM0W3vHYsKDloNRhRK87UbN798aiYk1g6w51OL7ClxlGStpZoRtTAA+enG2g55Vhx7WUM0kKvYw44iSWH60NN+XCItdHrGB6hBNf9Q86h+fzv2U92PvZOEjdX2PaNZ/2RR3QA6kf1ra8Na5RdXu3wvAZx+qAzrPXP8TGShcMc1kdYFC/RPzkUrj0Y2il3LXO7gAo1fi+RyZi9y0vvK3YNDHqxVE+dmMNYz9Ipsy2QBHF7vowJajvJVEAn8DQDSeQqRWwVeQZPTywzZbG8Ng0HlNV1QjUQbh3ZB3lWUdu5RQqD+Tltzo6fWkkN49FiYse/zlrIiUSayvALcGxeyvKTa0udIO2mGZO94aY/pg5uhG4/dHNk3JWRI2QyE0RyxCBRn9YksMPXVgkQ/ARgIbqrNP22JLFeffeB+zfBQQiPGsfnqTr8RWTyzlkltom6Uh5dksn7WfnbTofQbMIw6bU9x15+tmoxgJm3QzTnandpVXOsxSx5M2NJyTYIvkKegbJcRS0C4AiUeLDhm4feN/fg6oSRV4m+qpeFug0bO0AqjjKaaYOMHS6FoyT0osoLECMg0NjFdSuOVAdp7eB3sZD3nTtTPsnayyj+3uip+ajNhahw== ian@DESKTOP-C07E16P";
  tmuxSocket = "${homeDir}/vintagestory.sock";
  vs-console = pkgs.writeShellScriptBin "vs-console" ''
    sudo -u ${user} ${pkgs.tmux}/bin/tmux -S ${tmuxSocket} attach -t vintage-story
  '';
in {
  options.services.homelab.vintageStory = {
    enable = mkEnableOption "Enable Vintage Story Dedicated Server";

    sshKeys = mkOption {
      type = types.listOf types.str;
      default = [ christianSshPublicKey ianSshPublicKey ]; 
      description = "SSH public keys for server access";
    };

    port = mkOption {
      type = types.port;
      default = 42420;
      description = "The port the server listens on";
    };
  };

  config = mkIf cfg.enable {
    # 1. Allow Unfree (Vintage Story is not open source)
    # Note: You may need this in your global configuration.nix as well
    nixpkgs.config.allowUnfree = true;

    # 2. Networking
    networking.firewall.allowedTCPPorts = [ cfg.port ];
    networking.firewall.allowedUDPPorts = [ cfg.port ];

    # 3. User Setup
    users.groups.${group} = {};
    users.users.${user} = {
      group = group;
      isSystemUser = true;
      description = "Vintage Story Server User";
      shell = pkgs.bash;
      home = homeDir;
      createHome = true;
      packages = with pkgs; [
        pkgs-unstable.vintagestory # The unstable package for latest features
        screen
        tmux
      ];
      openssh.authorizedKeys.keys = cfg.sshKeys;
    };

    # 4. The Systemd Service
    systemd.services.vintage-story = {
      description = "Vintage Story Dedicated Server";
      after = [ "network.target" ];
      wants = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User = user;
        Group = group;
        WorkingDirectory = homeDir;

        Type = "forking"; # Tmux detaches, so systemd needs to know it's a fork

        ExecStart = pkgs.writeShellScript "start-vintage-story" ''
          # Clean up any existing socket
          rm -f ${tmuxSocket}
          # Start tmux session with proper permissions
          ${pkgs.tmux}/bin/tmux -S ${tmuxSocket} new-session -d -s vintage-story
          # Set socket permissions so the user can access it
          chmod 660 ${tmuxSocket}
          # Send the server command to the session
          ${pkgs.tmux}/bin/tmux -S ${tmuxSocket} send-keys '${pkgs-unstable.vintagestory}/bin/vintagestory-server --dataPath ${dataDir}' ENTER
        '';
        ExecStop = pkgs.writeShellScript "stop-vintage-story" ''
          if ${pkgs.tmux}/bin/tmux -S ${tmuxSocket} has-session -t vintage-story 2>/dev/null; then
            ${pkgs.tmux}/bin/tmux -S ${tmuxSocket} send-keys -t vintage-story "/stop" ENTER
            # Wait a bit for graceful shutdown
            sleep 10
            # Kill session if still running
            ${pkgs.tmux}/bin/tmux -S ${tmuxSocket} kill-session -t vintage-story 2>/dev/null || true
          fi
          rm -f ${tmuxSocket}
        '';
        Restart = "always";
        RestartSec = "120s";
        TimeoutStopSec = 360;
        KillMode = "mixed";

        # Standard memory/cpu limits (matching your Satisfactory style)
        MemoryAccounting = true;
        CPUAccounting = true;
      };

      preStart = ''
        mkdir -p ${dataDir}
        chown -R ${user}:${group} ${dataDir}
        # Clean up any leftover socket
        rm -f ${tmuxSocket}
        # Ensure the user can write to home directory for socket
        chown ${user}:${group} ${homeDir}
      '';
    };
  };
}