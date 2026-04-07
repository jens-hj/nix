{
  description = "Nixos config flake";

  inputs = {
    # Nix packages and Home Manager
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix darwin for MacOS
    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix WSL for WSL
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Theming
    catppuccin.url = "github:catppuccin/nix";
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-colors.url = "github:misterio77/nix-colors";
    # awww.url = "git+https://codeberg.org/LGFae/awww";

    # Desktop Environment
    vicinae.url = "github:vicinaehq/vicinae"; # tell Nixos where to get Vicinae
    niri.url = "github:sodiboo/niri-flake";
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Fish plugins
    git-fish = {
      url = "github:kpbaks/git.fish";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Gaming
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";

    # Browsers
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    # Firefox/browser extensions
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # T3 Code
    t3code.url = "github:omarcresp/t3code-flake";
  };

  outputs = {
    self,
    nix-darwin,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: {
    homeManagerModules.default = ./modules/home;
    nixosModules.default = ./modules/nixos;

    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        ./hosts/default/configuration.nix
        home-manager.nixosModules.default
        self.nixosModules.default
        inputs.catppuccin.nixosModules.catppuccin
      ];
    };
    nixosConfigurations."gmk" = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        ./hosts/gmk/configuration.nix
        home-manager.nixosModules.default
        self.nixosModules.default
        inputs.catppuccin.nixosModules.catppuccin
      ];
    };
    nixosConfigurations."rp4j" = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        ./hosts/rp4j/configuration.nix
        home-manager.nixosModules.default
        self.nixosModules.default
        inputs.catppuccin.nixosModules.catppuccin
        inputs.stylix.nixosModules.stylix
      ];
    };
    nixosConfigurations."desktop" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        nur = inputs.nur.legacyPackages.x86_64-linux;
      };
      modules = [
        ./hosts/desktop/configuration.nix
        home-manager.nixosModules.default
        self.nixosModules.default
        inputs.catppuccin.nixosModules.catppuccin
        inputs.stylix.nixosModules.stylix
      ];
    };
    nixosConfigurations."systematic" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = [
        ./hosts/systematic/configuration.nix
        home-manager.nixosModules.default
        self.nixosModules.default
        inputs.nixos-wsl.nixosModules.wsl
        inputs.catppuccin.nixosModules.catppuccin
        inputs.stylix.nixosModules.stylix
      ];
    };
    # Install `nix-darwin` from https://github.com/nix-darwin/nix-darwin?tab=readme-ov-file#readme
    # Build darwin flake using:
    # $ darwin-rebuild switch --flake ./<path>/<to>/<this>/<repo>/#macbook
    # Or for the first time to get nix-darwin initially:
    # $ sudo nix run github:lnl7/nix-darwin/master -- switch --flake ./<path>/<to>/<this>/<repo>/#macbook
    darwinConfigurations."macbook" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = {inherit inputs;};
      modules = [
        ./hosts/macbook/configuration.nix
        home-manager.darwinModules.home-manager
        self.nixosModules.default
      ];
    };
  };
}
