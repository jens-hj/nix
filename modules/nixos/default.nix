{
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ./srv/minecraft.nix
    ./srv/cluster-node.nix
    ./visuals/theme.nix
    ./desktop/noctalia.nix
    ./srv/k3s-agent.nix
  ];

  srv.minecraft.enable = lib.mkDefault false;
  srv.k3s.agent.enable = lib.mkDefault false;
  srv.clusterNode.enable = lib.mkDefault false;

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
