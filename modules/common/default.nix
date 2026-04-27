{
  inputs,
  ...
}: {
  home-manager = {
    backupFileExtension = "before-home-manager";
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs;};
  };

  programs.fish.enable = true;

  time.timeZone = "Europe/Copenhagen";
}
