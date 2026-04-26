{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";
    stylix.url = "github:danth/stylix";
    niri.url = "github:sodiboo/niri-flake";

    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-minecraft.url = "github:Infinidoge/nix-minecraft";

    git.url = "github:kpbaks/git.fish";
    ctrl-z.url = "github:kpbaks/ctrl-z.fish";
    autols.url = "github:kpbaks/autols.fish";
    border.url = "github:kpbaks/border.fish";
    what-changed.url = "github:kpbaks/what-changed.fish";
  };

  outputs = { self, nix-darwin, nixpkgs, home-manager, ... }@inputs: {
    homeManagerModules.default = ./modules/home;
    nixosModules.default = ./modules/nixos;

    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      # inherit pkgs;
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/default/configuration.nix
        home-manager.nixosModules.default
        self.nixosModules.default
        inputs.catppuccin.nixosModules.catppuccin
      ];
    };
    nixosConfigurations."gmk" = nixpkgs.lib.nixosSystem {
      # inherit pkgs;
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/gmk/configuration.nix
        home-manager.nixosModules.default
        self.nixosModules.default
        inputs.catppuccin.nixosModules.catppuccin
      ];
    };
    # Install `nix-darwin` from https://github.com/nix-darwin/nix-darwin?tab=readme-ov-file#readme
    # Build darwin flake using:
    # $ darwin-rebuild switch --flake ./<path>/<to>/<this>/<repo>/#macbook
    # Or for the first time to get nix-darwin initially:
    # $ sudo nix run github:lnl7/nix-darwin/master -- switch --flake ./<path>/<to>/<this>/<repo>/#macbook
    darwinConfigurations."macbook" = nix-darwin.lib.darwinSystem {
      # inherit pkgs;
      system = "aarch64-darwin";
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/macbook/configuration.nix
        home-manager.darwinModules.home-manager
        self.nixosModules.default
        {
          nixpkgs.overlays = [
            inputs.git.overlays.default
            inputs.ctrl-z.overlays.default
            inputs.what-changed.overlays.default
            inputs.autols.overlays.default
            inputs.border.overlays.default
          ];
        }
      ];
    };
  };
}
