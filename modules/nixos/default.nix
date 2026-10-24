{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../common
    ./srv/minecraft.nix
    ./srv/cluster-node.nix
    ./visuals/theme.nix
    ./desktop/noctalia.nix
    ./srv/k3s-agent.nix
    ./srv/nas.nix
    ./srv/zigbee.nix
  ];

  srv.minecraft.enable = lib.mkDefault false;
  srv.k3s.agent.enable = lib.mkDefault false;
  srv.clusterNode.enable = lib.mkDefault false;
  srv.nas.enable = lib.mkDefault false;
  srv.zigbee.enable = lib.mkDefault false;

  visuals.theme.enable = true;
  desktop.noctalia.enable = true;

  users.defaultUserShell = pkgs.fish;

  programs.nix-ld.enable = true;
}
