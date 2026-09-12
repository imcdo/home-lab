# ZeroTier Edge Reverse Proxy

This setup is managed in Kubernetes/GitOps.

The edge gateway is defined at:
- clusters/k3s/apps/zt-edge-gateway/zt-edge-gateway.yaml

Routes exposed by the gateway host `zt-gateway.home.lan`:
- `/grafana` -> `kube-prometheus-stack-grafana.monitoring.svc.cluster.local`
- `/prometheus` -> `kube-prometheus-stack-prometheus.monitoring.svc.cluster.local`
- `/pki` -> `ca-publisher.cert-manager.svc.cluster.local`
- `/vaultwarden` -> `vaultwarden.vaultwarden.svc.cluster.local`

TLS is terminated by Traefik using a cert-manager Certificate (`zt-edge-gateway-tls`) signed by `home-lan-ca`.

## ZeroTier configuration

1. Add a managed route to your homelab subnet/LB subnet in ZeroTier.
2. Ensure ZeroTier clients use DNS that resolves `zt-gateway.home.lan`.
3. Confirm connectivity:
   - `https://zt-gateway.home.lan/grafana`
   - `https://zt-gateway.home.lan/prometheus`
   - `https://zt-gateway.home.lan/pki`

## Notes

- Ingress and reverse proxy behavior are managed by cluster manifests, not Nix host services.
- Cilium L2 announcements handle LAN VIP advertisement; ZeroTier access relies on managed routes.
