{ config, pkgs, lib, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "nix";
  home.homeDirectory = "/home/nix";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05";

  catppuccin = {
    enable = true;
    flavor = "mocha";
  };

  nixpkgs.config.allowUnfree = true;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    mcrcon
    tokei
    ripgrep
    ripgrep-all
    alejandra
    nix-prefetch-github
    nixfmt-classic
    nerd-fonts.jetbrains-mono
  ];

  # Enable the custom base configuration from ./../../modules/default.nix
  base.enable = true;
  ghostty.enable = lib.mkForce true;

  programs = {
    # Enable home-manager itself
    home-manager.enable = true;
    # Other
    direnv.enable = true;
    fzf.enable = true;
    ssh.enable = true;
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
