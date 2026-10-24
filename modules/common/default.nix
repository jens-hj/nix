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

  # Fish plugins (fishPlugins.*) used by modules/home/shell/fish.nix
  nixpkgs.overlays = [
    inputs.git.overlays.default
    inputs.ctrl-z.overlays.default
    inputs.what-changed.overlays.default
    inputs.autols.overlays.default
    inputs.border.overlays.default
  ];

  programs.fish.enable = true;

  time.timeZone = "Europe/Copenhagen";
}
