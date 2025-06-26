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
  };
  outputs = inputs@{ self, nixpkgs, comin, vscode-server, disko, ... }:
  let
    lib = nixpkgs.lib;
  in {
    nixosConfigurations = {
      think = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          comin.nixosModules.comin
          ({...}: {
            services.comin = {
              enable = true;
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
          ./modules/flux-bootstrap.nix
        ];
      };
    };
  };
}