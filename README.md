Ian's homelab setup with nix


## macOS

The MacBook configuration lives under `nix#darwinConfigurations.macbook`. Once nix-darwin is installed, switch it with:

```bash
darwin-rebuild switch --flake ./nix#macbook
```

# Todo
- private tls certs and cert authority
- setup firefly
- setup windows node exporter
- 