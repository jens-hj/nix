{
  inputs,
  pkgs,
  lib,
  ...
}: {
  # imports = [
  #   ./srv/minecraft.nix
  # ];

  home-manager = {
    backupFileExtension = "before-home-manager";
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs;};
  };

  # environment.shells = with pkgs; [fish];
  programs.fish.enable = true;

  time.timeZone = "Europe/Copenhagen";
}
