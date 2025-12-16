{ inputs, ... }:
{
  imports = [
    ./srv/minecraft.nix
    ./visuals/theme.nix
  ];

  srv.minecraft.enable = false;
  visuals.theme.enable = true;

  home-manager = {
    backupFileExtension = "before-home-manager";
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
  };

  programs.fish.enable = true;
  programs.nix-ld.enable = true;

  time.timeZone = "Europe/Copenhagen";
}
