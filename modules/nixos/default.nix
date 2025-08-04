{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./minecraft.nix
  ];

  home-manager = {
    backupFileExtension = "before-home-manager";
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs;};
  };

  time.timeZone = "Europe/Copenhagen";

  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
}
