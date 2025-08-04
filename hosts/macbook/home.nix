{
  pkgs,
  lib,
  ...
}: {
  home.stateVersion = "24.05";

  # nixpkgs.config.allowUnfree has been moved to system-level configuration

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    aichat
    mcrcon
    just
    pixi
    pgweb
    dconf
    k9s
  ];

  # Enable the custom base configuration from ./../../modules/default.nix
  base.enable = true;
  shell.brew.enable = lib.mkForce true;
  typesetters.typst.enable = lib.mkForce true;

  home.sessionVariables = {
    MCRCON_HOST = "192.168.0.188";
    MCRCON_PASS = "7568";
    CARGO_HOME = "/Users/jens/.cargo";
    COLORTERM = "truecolor";
    fish_term24bit = "1";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    RELEASE_CONTAINER_ENGINE = "docker";
    DIRENV_LOG_FORMAT = "";
    TERM = "xterm-256color";
  };
}
