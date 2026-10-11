{
  pkgs,
  inputs,
  ...
}: {
  wsl.enable = true;
  wsl.defaultUser = "j";
  networking.hostName = "nixos-wsl";

  programs.fish.enable = true;
  users.users.j.shell = pkgs.fish;
  programs.nix-ld.enable = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "before-home-manager";
    extraSpecialArgs = {inherit inputs;};
    users.j = import ./home.nix;
  };

  # Preserve the state defaults of this newly installed system.
  system.stateVersion = "26.05";
}
