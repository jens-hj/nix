{
  pkgs,
  ...
}: {
  imports = [
    ../common
    ./srv/minecraft.nix
    ./visuals/theme.nix
    ./desktop/noctalia.nix
    ./srv/k3s-agent.nix
  ];

  srv.minecraft.enable = false;
  srv.k3s.agent.enable = false;

  visuals.theme.enable = true;
  desktop.noctalia.enable = true;

  users.defaultUserShell = pkgs.fish;

  programs.nix-ld.enable = true;
}
