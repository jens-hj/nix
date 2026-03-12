{
  pkgs,
  lib,
  ...
}: {
  home.username = "nix";
  home.homeDirectory = "/home/nix";

  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    mcrcon
  ];

  # Enable the custom base configuration from ./../../modules/default.nix
  base.enable = true;
  visuals.theme.enable = lib.mkForce false;
  # terminal.ghostty.enable = lib.mkForce true;
  shell.fish.zellij.autoStart = lib.mkForce false;
  utils.cli.profile = lib.mkForce "extended";

  # programs = {
  #   firefox = {
  #     enable = true;
  #     profiles.default.extensions.force = true;
  #   };
  # };

  home.sessionVariables = {
    MCRCON_HOST = "localhost";
    MCRCON_PASS = "7568";
    COLORTERM = "truecolor";
    fish_term24bit = "1";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    TERM = "xterm-256color";
  };
}
