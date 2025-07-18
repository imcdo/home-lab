{
  inputs = {
    nixpkgs.url = "github:nixOS/nixpkgs";
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
  };
  outputs = inputs@{ self, nixpkgs, comin, vscode-server, disko, agenix, ... }:
  let
    lib = nixpkgs.lib;
  in {
    nixosConfigurations = {
      think = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          comin.nixosModules.comin
          agenix.nixosModules.default
          ({...}: {
            services.comin = {
              enable = true;
              hostname = "think";
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
          ./hosts/think/disk-config.nix
          ./hosts/think/hardware-configuration.nix
          ./hosts/think/configuration.nix
          ./modules/k3s.nix
          ./modules/users.nix
        ];
      };
      chrome-a = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          comin.nixosModules.comin
          agenix.nixosModules.default
          ({...}: {
            services.comin = {
              enable = true;
              hostname = "chrome-a";
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
          ./hosts/chrome-a/disk-config.nix
          ./hosts/chrome-a/hardware-configuration.nix
          ./hosts/chrome-a/configuration.nix
          ./modules/k3s.nix
          ./modules/users.nix
        ];
      };
      chrome-b = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          comin.nixosModules.comin
          agenix.nixosModules.default
          ({...}: {
            services.comin = {
              enable = true;
              hostname = "chrome-b";
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
          ./hosts/chrome-b/disk-config.nix
          ./hosts/chrome-b/hardware-configuration.nix
          ./hosts/chrome-b/configuration.nix
          ./modules/k3s.nix
          ./modules/users.nix
        ];
      };
    };
  };
}