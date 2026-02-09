{
  # Home lab infrastructure configuration
  # refer to template here https://github.com/Misterio77/nix-starter-configs

  description = "Ian's home lab NixOS configurations";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixOS/nixpkgs/nixos-24.11";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # nixos-anywhere for remote deployments
    nixos-anywhere.url = "github:nix-community/nixos-anywhere";

    # Comin for GitOps-style deployments
    comin = {
      url = "github:nlewo/comin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Disko for declarative disk partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # VSCode server support
    vscode-server.url = "github:nix-community/nixos-vscode-server";

    # agenix for secrets management
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
    # Supported systems for your flake packages, shell, etc.
    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;

    # Define overlays to extend nixpkgs
    overlays = {
      # Add unstable packages as pkgs.unstable
      unstable-packages = final: _prev: {
        unstable = import inputs.nixpkgs-unstable {
          inherit (final) system;
          config.allowUnfree = true;
        };
      };
    };

    sshConfig = {
      defaultPublicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDJwCoP+9JDU6mH4pZCsk/GlhDXiarbdyaakIB1DzLMRtiv79U/aTkTvgm/TTmeQLM0W3vHYsKDloNRhRK87UbN798aiYk1g6w51OL7ClxlGStpZoRtTAA+enG2g55Vhx7WUM0kKvYw44iSWH60NN+XCItdHrGB6hBNf9Q86h+fzv2U92PvZOEjdX2PaNZ/2RR3QA6kf1ra8Na5RdXu3wvAZx+qAzrPXP8TGShcMc1kdYFC/RPzkUrj0Y2il3LXO7gAo1fi+RyZi9y0vvK3YNDHqxVE+dmMNYz9Ipsy2QBHF7vowJajvJVEAn8DQDSeQqRWwVeQZPTywzZbG8Ng0HlNV1QjUQbh3ZB3lWUdu5RQqD+Tltzo6fWkkN49FiYse/zlrIiUSayvALcGxeyvKTa0udIO2mGZO94aY/pg5uhG4/dHNk3JWRI2QyE0RyxCBRn9YksMPXVgkQ/ARgIbqrNP22JLFeffeB+zfBQQiPGsfnqTr8RWTyzlkltom6Uh5dksn7WfnbTofQbMIw6bU9x15+tmoxgJm3QzTnandpVXOsxSx5M2NJyTYIvkKegbJcRS0C4AiUeLDhm4feN/fg6oSRV4m+qpeFug0bO0AqjjKaaYOMHS6FoyT0osoLECMg0NjFdSuOVAdp7eB3sZD3nTtTPsnayyj+3uip+ajNhahw== ian@DESKTOP-C07E16P";
    };

    mkCommonModules = hostname: [
      inputs.disko.nixosModules.disko
      inputs.comin.nixosModules.comin
      inputs.agenix.nixosModules.default
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
      inputs.vscode-server.nixosModules.default
      ({ config, pkgs, ... }: {
        services.vscode-server.enable = true;
      })
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        # Use the common home configurations from a separate file
        home-manager.extraSpecialArgs = { inherit inputs outputs sshConfig; };
        home-manager.users = {
          ian = import ./home/users/ian;
        };
      }
      ./modules/k3s.nix
      ./modules/users.nix
    ];

    machine = name: modules:
      nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs outputs;
        };
        modules =
          [
            # Apply overlays to make unstable packages available as pkgs.unstable
            ({ config, pkgs, ... }: {
              nixpkgs.overlays = [ overlays.unstable-packages ];
            })
            ./hosts/${name}/disk-config.nix
            ./hosts/${name}/hardware-configuration.nix
            ./hosts/${name}/configuration.nix
          ]
          ++ modules
          ++ (mkCommonModules name);
      };
  in {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});

    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Your custom packages and modifications, exported as overlays
    overlays = overlays;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild switch --flake .#your-hostname'
    nixosConfigurations = {
      think = machine "think" [];
      chrome-a = machine "chrome-a" [];
      chrome-b = machine "chrome-b" [];
      chrome-c = machine "chrome-c" [];
      busy-bee = machine "busy-bee" [
        ./modules/satisfactory-server.nix
        ./modules/vintage-story-server.nix
      ];
    };
  };
}