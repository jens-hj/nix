{
  pkgs,
  inputs,
  ...
}: {
  imports = [../../modules/common];

  wsl.enable = true;
  wsl.defaultUser = "j";
  networking.hostName = "nixos-wsl";

  nixpkgs.overlays = [
    inputs.git.overlays.default
    inputs.ctrl-z.overlays.default
    inputs.what-changed.overlays.default
    inputs.autols.overlays.default
    inputs.border.overlays.default
  ];

  users.users.j.shell = pkgs.fish;
  programs.nix-ld.enable = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  home-manager.users.j = import ./home.nix;

  # Preserve the state defaults of this newly installed system.
  system.stateVersion = "26.05";
}
