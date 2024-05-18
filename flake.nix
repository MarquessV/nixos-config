{
  description = "Marquess' Flake";
  
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";	
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";	
  };

  outputs = inputs @ { self, nixpkgs, home-manager, ... }:
    let
    	systemSettings = {
	  system = "x86_64-linux";
	  hostname = "jefe";
	  profile = "personal";
	  timezone = "America/LosAngeles";
	  locale = "en_us.UTF-8";
	  bootMode = "uefi";
	  bootMountPath = "/boot";
	};
	userSettings = {
	  username = "marquessv";
	  name = "Marquess";
	  email = "marquessavaldez@gmail.com";
	  dotfilesDir = "~/.dotfiles";
	  term = "kitty";
	  font = "Iosevka";
	  editor = "nvim";
	};
    	lib = nixpkgs.lib;
	pkgs = nixpkgs.legacyPackages.${systemSettings.system};
	home-mangager = inputs.home-manager;
	supportedSystems = [ "x86_64-linux" ];
	forAllSystems = inputs.nixpkgs.lib.genAttrs supportedSystems;
	nixpkgsFor = forAllSystems (system: import inputs.nixpkgs { inherit system; });
  in {
    nixosConfigurations = {
      jefe = lib.nixosSystem {
        inherit systemSettings;
	modules = [ 
	  ./configuration.nix
	  ./hardware-configuration.nix
	];
	specialArgs = {
	  inherit userSettings;
	  inherit systemSettings;
	  inherit inputs;
	};
      };
    };
    homeConfigurations = {
       user = home-manager.lib.homeManagerConfiguration {
         inherit pkgs;
         modules = [ ./home.nix ];
	 extraSpecialArgs = {
	   inherit systemSettings;
	   inherit userSettings;
	   inherit inputs;
	 };
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
