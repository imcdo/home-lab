{ config, pkgs, lib, ... }:
let
  christianSshPublicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCgGX3jzujNs6a192SuIC75KUOsyGfTN6elM2CXtcuimnqxOOa19Ect6RMb9OVdNi4BkzIHvYrES9WJDFqYpaDzpX6yYmBeg47aKps+n16+Y1PPqU9DkJDNBbqXHb3YsHFX6jq+Dc7ledUy64hyrQuhID/jajSC7ZSOiFLfzpX7yjWMXjgciyIfDgmi68ZAyzHUODN1/Ab5fV6HLTiNSJbTzMoVyvb9f86uCTdbCYEEk0pLCoRZoUaBMD+hvXu0NM8nclXT1bWe7nVSijaLeBOLAG8SGEun7LxN7jbVFmHtUDg/rT33ACmZHVHLNu6P47oJ4YyILuXzK7wWCZVb7vU4lP9HBbfgWCNRtiNokGzyi2Y5amGWqWvxPEKSRTXSTXie18XyjehFkLuKCjvLOykYGSQA7NM3mEDqBeiaKyB9Sl4kF9gEOWZ24mHQqIxbMFWY60IdnPqpF1KLy1oVg0KnxmC2LCbd4GSMm2vzgEPNM+F/nfVW4CcnLqiI1AmW3q9GX4BYDX9KcRYaqrzA2sNGlvCAnpr6XVP2OBBcTJCHCs4S3unUMiRlN7m1xWgAP2DNqjy5MObgau8JDjvV8Xcv7fLwDTKxPJTzZGGPazQq3brIbXGKhkQNXdghVe7Ld8OV5uzyEUQQoUiYER2Hh5ATukNkM3qvpAtjaGZcsHPt9Q== christian@grandlan.dev";
  ianSshPublicKey ="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDJwCoP+9JDU6mH4pZCsk/GlhDXiarbdyaakIB1DzLMRtiv79U/aTkTvgm/TTmeQLM0W3vHYsKDloNRhRK87UbN798aiYk1g6w51OL7ClxlGStpZoRtTAA+enG2g55Vhx7WUM0kKvYw44iSWH60NN+XCItdHrGB6hBNf9Q86h+fzv2U92PvZOEjdX2PaNZ/2RR3QA6kf1ra8Na5RdXu3wvAZx+qAzrPXP8TGShcMc1kdYFC/RPzkUrj0Y2il3LXO7gAo1fi+RyZi9y0vvK3YNDHqxVE+dmMNYz9Ipsy2QBHF7vowJajvJVEAn8DQDSeQqRWwVeQZPTywzZbG8Ng0HlNV1QjUQbh3ZB3lWUdu5RQqD+Tltzo6fWkkN49FiYse/zlrIiUSayvALcGxeyvKTa0udIO2mGZO94aY/pg5uhG4/dHNk3JWRI2QyE0RyxCBRn9YksMPXVgkQ/ARgIbqrNP22JLFeffeB+zfBQQiPGsfnqTr8RWTyzlkltom6Uh5dksn7WfnbTofQbMIw6bU9x15+tmoxgJm3QzTnandpVXOsxSx5M2NJyTYIvkKegbJcRS0C4AiUeLDhm4feN/fg6oSRV4m+qpeFug0bO0AqjjKaaYOMHS6FoyT0osoLECMg0NjFdSuOVAdp7eB3sZD3nTtTPsnayyj+3uip+ajNhahw== ian@DESKTOP-C07E16P";
  satisfactoryDataDir = "/home/steam/satisfactory";

in {
  users.users.steam =  {
    group = "steam";
    isSystemUser = true;
    description = "Steam User";
    shell = pkgs.bash;
    home = "/home/steam";
    packages = with pkgs; [
      steamcmd
      git
      tmux
    ];
    openssh.authorizedKeys.keys = [
      christianSshPublicKey
    ];
  };

  # Satisfactory server

  systemd.services.satisfactory-server = {
    description = "Satisfactory Dedicated Server";
    after = [ "network.target" ];
    wants = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      User = "steam";
      Group = "steam";

      WorkingDirectory = satisfactoryDataDir;

      ExecStart = "${satisfactoryDataDir}/FactoryServer.sh";

      # prevent systemd assuming it daemonizes itself
      Type = "simple";

      # Always restart on crash
      Restart = "always";
      RestartSec = "5s";

      MemoryAccounting = true;
      MemoryMax = "4G";

      CPUAccounting = true;
      CPUQuota = "60%";
    };

    preStart = ''
      mkdir -p ${satisfactoryDataDir}
      chown steam:steam ${satisfactoryDataDir}

      ${pkgs.steamcmd}/bin/steamcmd \
          +force_install_dir ${satisfactoryDataDir} \
          +login anonymous \
          +app_update 1690800 validate \
          +quit
    '';

    requires = [ "network-online.target" ];
  };
}