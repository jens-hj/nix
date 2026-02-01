{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./srv/minecraft.nix
    ./visuals/theme.nix
    ./desktop/noctalia.nix
  ];

  srv.minecraft.enable = false;
  visuals.theme.enable = true;
  desktop.noctalia.enable = true;

  home-manager = {
    backupFileExtension = "before-home-manager";
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs;};
  };

  users.defaultUserShell = pkgs.fish;

  programs.fish.enable = true;
  programs.nix-ld.enable = true;

  time.timeZone = "Europe/Copenhagen";
}
