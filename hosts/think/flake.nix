{
  inputs = {
    nixpkgs.url = "github:nixOS/nixpkgs";
    comin = {
      url = "github:nlewo/comin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, comin }: {
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
                url = "https://gitlab.com/imcdo/home-lab.git";
                branches.main.name = "main";
              }];
              flakeSubdirectory = "hosts/think";
            };
          })
          ./configuration.nix
        ];
      };
    };
  };
}