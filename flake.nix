{
  description = "Marquess' Flake";
  
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";	
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";	
  };

  outputs = inputs @ { self, nixpkgs, home-manager, ... }:
    let
    	lib = nixpkgs.lib;
	system = "x86_64-linux";
	pkgs = nixpkgs.legacyPackages.${system};
	supportedSystems = [ "x86_64-linux" ];
	forAllSystems = inputs.nixpkgs.lib.genAttrs supportedSystems;
	nixpkgsFor = forAllSystems (system: import inputs.nixpkgs { inherit system; });
  in {
    nixosConfigurations = {
      jefe = lib.nixosSystem {
        inherit system;
	modules = [ 
	  ./configuration.nix
	  ./hardware-configuration.nix
	];
      };
    };
    homeConfigurations = {
       marquess = home-manager.lib.homeManagerConfiguration {
         inherit pkgs;
         modules = [ ./home.nix ];
       };
    };

    packages = forAllSystems (system:
      let pkgs = nixpkgsFor.${system};
      in {
        default = self.packages.${system}.install;
	install = pkgs.writeShellApplication {
	  name = "install";
	  text = ''${./install.sh}'';
	};	
      });
    
    apps = forAllSystems (system: {
      default = self.apps.${system}.install;
      install = {
        type = "app";
	program = "${self.packages.${system}.install}/bin/install";
      };
    });
  };
}
