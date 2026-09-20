{pkgs, ...}: {
  imports = [
    ../common
    ./srv/minecraft.nix
    ./visuals/theme.nix
    ./desktop/noctalia.nix
    ./srv/k3s-agent.nix
    ./srv/nas.nix
    ./srv/zigbee.nix
  ];

  srv.k3s.agent.enable = false;
  srv.minecraft.enable = false;
  srv.nas.enable = false;
  srv.zigbee.enable = false;

  visuals.theme.enable = true;
  desktop.noctalia.enable = true;

  users.defaultUserShell = pkgs.fish;

  programs.nix-ld.enable = true;
}
