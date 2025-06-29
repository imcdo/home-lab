{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.homelab.k3s;
in
{
  options.services.homelab.k3s = {
    enable = mkEnableOption "Enable K3s Kubernetes cluster";

    role = mkOption {
      type = types.enum [ "server" "agent" ];
      default = "server";
      description = "Role of this node: server (control plane) or agent (worker)";
    };

    clusterInit = mkOption {
      type = types.bool;
      default = true;
      description = "Initialize a new cluster (only set true for the first server node)";
    };

    serverAddr = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "https://192.168.1.100:6443";
      description = "Address of existing server to join (required for additional nodes)";
    };

    token = mkOption {
      type = types.str;
      default = "homelab-k3s-token";
      description = "Cluster token for authentication";
    };

    hostName = mkOption {
      type = types.str;
      default = config.networking.hostName;
      description = "Hostname for this node";
    };
  };

  config = mkIf cfg.enable {
    # Install packages
    environment.systemPackages = with pkgs; [
      kubectl
      kubernetes-helm
      cilium-cli
      fluxcd
    ];

    # Set KUBECONFIG
    environment.variables.KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";

    # Users and groups
    users.groups.k3s = {};
    users.users.k3s = {
      isSystemUser = true;
      group = "k3s";
      home = "/var/lib/rancher/k3s";
      createHome = true;
      description = "K3s System User";
      shell = "/sbin/nologin";
    };

    # Firewall
    networking.firewall = {
      allowedTCPPorts = [
        22    # SSH
        6443  # k3s API
        2379  # etcd client
        2380  # etcd peer
        4240  # Cilium health
        4245  # Hubble relay
        4222  # Hubble health
      ];
      allowedUDPPorts = [
        53    # DNS
        8472  # Flannel VXLAN
        4789  # Cilium VXLAN
      ];
      trustedInterfaces = [
        "cilium_host"
        "cilium_net"
        "cilium_vxlan"
        "cilium_geneve"
      ];
    };

    # BPF support for Cilium
    boot.kernelModules = [ "bpf" ];
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
      "net.core.bpf_jit_enable" = 1;
      "net.core.bpf_jit_harden" = 0;
    };

    # Set hostname
    networking.hostName = cfg.hostName;

    # K3s service - simplified version of your current config
    services.k3s = {
      enable = true;
      token = cfg.token;
      role = "server";
      clusterInit = cfg.clusterInit;
      serverAddr = cfg.serverAddr;
      extraFlags = toString [
        "--write-kubeconfig-mode=640"
        "--write-kubeconfig-group=k3s"
        "--flannel-backend=none"
        "--disable-network-policy"
        "--cluster-cidr=10.42.0.0/16"
        "--service-cidr=10.43.0.0/16"
      ];
    };
  };
}
