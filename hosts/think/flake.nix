{
  inputs = {
    nixpkgs.url = "github:nixOS/nixpkgs";
    comin = {
      url = "github:nlewo/comin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server.url = "github:nix-community/nixos-vscode-server";
  };
  outputs = { self, nixpkgs, comin, vscode-server }: {
    nixosConfigurations = {
      think = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          comin.nixosModules.comin
          ({...}: {
            services.comin = {
              enable = true;
              remotes = [{
                name = "origin";
                url = "https://github.com/imcdo/home-lab.git";
                branches.main.name = "main";
              }];
              flakeSubdirectory = "./hosts/think";
            };
          })
          vscode-server.nixosModules.default
          ({ config, pkgs, ... }: {
            services.vscode-server.enable = true;
          })
          ./configuration.nix
          ../modules/flux-bootstrap.nix
        ];
      };
    };
  };
}