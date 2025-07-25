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
  };

  outputs = { self, nix-darwin, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        home-manager.nixosModules.default
        # inputs.stylix.homeManagerModules.stylix
        # inputs.stylix.nixosModules.stylix
        inputs.catppuccin.nixosModules.catppuccin
        {
          home-manager.users.jens = {
            # extraSpecialArgs = { inherit inputs; };
            imports = [
              ./home.nix
              inputs.catppuccin.homeManagerModules.catppuccin
              inputs.stylix.homeManagerModules.stylix
              inputs.niri.homeModules.niri
            ];
          };
        }
      ];
    };
    # Install `nix-darwin` from https://github.com/nix-darwin/nix-darwin?tab=readme-ov-file#readme
    # Build darwin flake using:
    # $ darwin-rebuild switch --flake .#macbook
    darwinConfigurations."macbook" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = { inherit inputs; };
      modules = [
        ./darwin.nix
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            backupFileExtension = "before-nix-darwin";
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit inputs; };
            users.jens = { pkgs, ... }: {
              imports = [
                ./home.nix
                inputs.catppuccin.homeManagerModules.catppuccin
              ];
            };
          };
        }
      ];
    };
  };
}
