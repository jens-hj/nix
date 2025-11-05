{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-colors.url = "github:misterio77/nix-colors";

    vicinae.url = "github:vicinaehq/vicinae"; # tell Nixos where to get Vicinae

    niri.url = "github:sodiboo/niri-flake";

    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-minecraft.url = "github:Infinidoge/nix-minecraft";

    # zen-browser.url = "github:0xc000022070/zen-browser-flake";
  };

  outputs =
    {
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    {
      homeManagerModules.default = ./modules/home;
      nixosModules.default = ./modules/nixos;

      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/default/configuration.nix
          home-manager.nixosModules.default
          self.nixosModules.default
          inputs.catppuccin.nixosModules.catppuccin
        ];
      };
      nixosConfigurations."gmk" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/gmk/configuration.nix
          home-manager.nixosModules.default
          self.nixosModules.default
          inputs.catppuccin.nixosModules.catppuccin
        ];
      };
      nixosConfigurations."desktop" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/desktop/configuration.nix
          home-manager.nixosModules.default
          self.nixosModules.default
          inputs.catppuccin.nixosModules.catppuccin
          inputs.stylix.nixosModules.stylix
          # inputs.zen-browser.nixosModules.zen-browser
        ];
      };
      # Install `nix-darwin` from https://github.com/nix-darwin/nix-darwin?tab=readme-ov-file#readme
      # Build darwin flake using:
      # $ darwin-rebuild switch --flake ./<path>/<to>/<this>/<repo>/#macbook
      # Or for the first time to get nix-darwin initially:
      # $ sudo nix run github:lnl7/nix-darwin/master -- switch --flake ./<path>/<to>/<this>/<repo>/#macbook
      darwinConfigurations."macbook" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/macbook/configuration.nix
          home-manager.darwinModules.home-manager
          self.nixosModules.default
        ];
      };
    };
}
