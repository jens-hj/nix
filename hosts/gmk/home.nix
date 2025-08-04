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
  terminal.ghostty.enable = lib.mkForce true;
  utils.cli.profile = lib.mkForce "extended";

  programs = {
    firefox = {
      enable = true;
      profiles.default.extensions.force = true;
    };
  };

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
