{ config, pkgs, ... }:

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
    # Enable GNOME Terminal styling
    gnome.enable = true;
    gnomeTerminal.enable = true;
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
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  # Enable the custom base configuration from ./../../modules/default.nix
  base.enable = true;

  programs = {
    # Enable home-manager itself
    home-manager.enable = true;
    # Terminal
    gnome-terminal = {
      enable = true;
      showMenubar = false;
      profile = {
        "b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = {
          default = true;
          visibleName = "Catppuccin";
          font = "JetBrainsMono Nerd Font 12";
          scrollOnOutput = true;
          showScrollbar = false;
        };
      };
    };
    # Other
    direnv.enable = true;
    fzf.enable = true;
    ssh.enable = true;
    firefox.enable = true;
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
