{
  inputs = {
    nixpkgs.url = "github:nixOS/nixpkgs";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-anywhere.url = "github:nix-community/nixos-anywhere";
    comin = {
      url = "github:nlewo/comin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
     home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs@{
    self,
    nixpkgs,
    comin,
    vscode-server,
    disko,
    agenix,
    home-manager,
    ...
  }:
  let
    lib = nixpkgs.lib;
    sshConfig = {
      defaultPublicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDJwCoP+9JDU6mH4pZCsk/GlhDXiarbdyaakIB1DzLMRtiv79U/aTkTvgm/TTmeQLM0W3vHYsKDloNRhRK87UbN798aiYk1g6w51OL7ClxlGStpZoRtTAA+enG2g55Vhx7WUM0kKvYw44iSWH60NN+XCItdHrGB6hBNf9Q86h+fzv2U92PvZOEjdX2PaNZ/2RR3QA6kf1ra8Na5RdXu3wvAZx+qAzrPXP8TGShcMc1kdYFC/RPzkUrj0Y2il3LXO7gAo1fi+RyZi9y0vvK3YNDHqxVE+dmMNYz9Ipsy2QBHF7vowJajvJVEAn8DQDSeQqRWwVeQZPTywzZbG8Ng0HlNV1QjUQbh3ZB3lWUdu5RQqD+Tltzo6fWkkN49FiYse/zlrIiUSayvALcGxeyvKTa0udIO2mGZO94aY/pg5uhG4/dHNk3JWRI2QyE0RyxCBRn9YksMPXVgkQ/ARgIbqrNP22JLFeffeB+zfBQQiPGsfnqTr8RWTyzlkltom6Uh5dksn7WfnbTofQbMIw6bU9x15+tmoxgJm3QzTnandpVXOsxSx5M2NJyTYIvkKegbJcRS0C4AiUeLDhm4feN/fg6oSRV4m+qpeFug0bO0AqjjKaaYOMHS6FoyT0osoLECMg0NjFdSuOVAdp7eB3sZD3nTtTPsnayyj+3uip+ajNhahw== ian@DESKTOP-C07E16P";
    };
    mkCommonModules = hostname: [
      disko.nixosModules.disko
      comin.nixosModules.comin
      agenix.nixosModules.default
      ({...}: {
        services.comin = {
          enable = true;
          hostname = hostname;
          remotes = [{
            name = "origin";
            url = "https://github.com/imcdo/home-lab.git";
            branches.main.name = "main";
          }];
          flakeSubdirectory = "./nix";
        };
      })
      vscode-server.nixosModules.default
      ({ config, pkgs, ... }: {
        services.vscode-server.enable = true;
      })
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        # Use the common home configurations from a separate file
        home-manager.extraSpecialArgs = { inherit inputs sshConfig; };
        home-manager.users = import ./home;
      }
      ./modules/k3s.nix
      ./modules/users.nix
    ];
  in {
    nixosConfigurations = {
      think = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/think/disk-config.nix
          ./hosts/think/hardware-configuration.nix
          ./hosts/think/configuration.nix
        ] ++ (mkCommonModules "think");
      };
      chrome-a = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/chrome-a/disk-config.nix
          ./hosts/chrome-a/hardware-configuration.nix
          ./hosts/chrome-a/configuration.nix
        ] ++ (mkCommonModules "chrome-a");
      };
      chrome-b = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/chrome-b/disk-config.nix
          ./hosts/chrome-b/hardware-configuration.nix
          ./hosts/chrome-b/configuration.nix
        ] ++ (mkCommonModules "chrome-b");
      };
      chrome-c = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/chrome-c/disk-config.nix
          ./hosts/chrome-c/hardware-configuration.nix
          ./hosts/chrome-c/configuration.nix
        ] ++ (mkCommonModules "chrome-c");
      };
    };
  };
}