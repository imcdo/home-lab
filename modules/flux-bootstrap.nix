{ config, lib, pkgs, ... }:

with lib;
{
  options.services.flux-bootstrap = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable FluxCD bootstrap via GitHub.";
    };

    githubOwner = mkOption {
      type = types.str;
      default = "imcdo";
      description = "GitHub owner for the repository to bootstrap.";
    };

    githubRepo = mkOption {
      type = types.str;
      default = "home-lab";
      description = "GitHub repository for the repository to bootstrap.";
    };

    path = mkOption {
      type = types.str;
      default = "clusters/k3s";
      description = "Path in the Git repo where manifests live.";
    };

    branch = mkOption {
      type = types.str;
      default = "main";
      description = "Git branch to use for bootstrap.";
    };
  };

  config = mkIf config.services.flux-bootstrap.enable {
    environment.systemPackages = with pkgs; [ fluxcd kubectl git openssh ];

    environment.etc."flux/bootstrap.sh".text = ''
      #!/bin/sh
      set -e
      if ! ${kubectl}/bin/kubectl get ns flux-system >/dev/null 2>&1; then
        echo "Flux not found in cluster, bootstrapping..."
        flux bootstrap github \
          --owner=${config.services.flux-bootstrap.githubOwner} \
          --repository=${config.services.flux-bootstrap.githubRepo} \
          --branch=${config.services.flux-bootstrap.branch} \
          --path=${config.services.flux-bootstrap.path} \
          --personal
      else
        echo "Flux already bootstrapped"
      fi
    '';

    systemd.services.flux-bootstrap = {
      description = "Bootstrap Flux into the K3s cluster";
      after = [ "k3s.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash /etc/flux/bootstrap.sh";
        Restart = "on-failure";
        TimeoutSec = 300;
      };
      path = with pkgs; [ fluxcd kubectl git openssh ];
    };
  };
}
