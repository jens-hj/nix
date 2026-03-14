{lib, ...}: {
  home.username = "pi";
  home.homeDirectory = "/home/pi";
  home.stateVersion = "26.05";

  # Enable the custom base configuration from ./../../modules/default.nix
  base.enable = true;
  shell.fish.zellij.autoStart = lib.mkForce false;
  utils.cli.profile = lib.mkForce "extended";

  home.sessionVariables = {
    COLORTERM = "truecolor";
    fish_term24bit = "1";
    TERM = "xterm-256color";
    NIXOS_DEFAULT_CONFIG = "rp4j";
  };
}
