{lib, ...}: {
  home.username = "pi";
  home.homeDirectory = "/home/pi";
  home.stateVersion = "26.05";

  base.enable = true;
  shell.fish.zellij.autoStart = lib.mkForce false;
  utils.cli.profile = lib.mkForce "extended";

  # Headless worker — no theming
  visuals.theme.enable = lib.mkForce false;

  home.sessionVariables = {
    COLORTERM = "truecolor";
    fish_term24bit = "1";
    TERM = "xterm-256color";
    NIXOS_DEFAULT_CONFIG = "rp5j";
  };
}
