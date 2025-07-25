{ config, pkgs, ... }:

{
  home.stateVersion = "24.05";

  catppuccin.flavor = "mocha";
  catppuccin.enable = true;

  nixpkgs.config.allowUnfree = true;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    croc
    aichat
    mcrcon
    typst
    typstfmt
    just
    pixi
    pgweb
    dconf
    dust
    grc
    pre-commit
    comma
    tokei
    ripgrep
    ripgrep-all
    tree
    sqlite
    bat
    eza
    tealdeer
    zip
    unzip
    duf
    wget
    curl
    alejandra
    difftastic
    nix-prefetch-github
    nixfmt-classic
    k9s
  ];

  base.enable = true;

  programs = {
    home-manager.enable = true;
    nil.enable = true;
    kitty = {
      enable = true;
      settings = {
        font_size = 14;
        confirm_os_window_close = 0;
        tab_bar_style = "hidden";
        hide_window_decorations = "yes";
        window_padding_width = 0;
        window_margin_width = 0;
      };
    };

    direnv.enable = true;
    fzf.enable = true;
    ssh.enable = true;
  };

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
