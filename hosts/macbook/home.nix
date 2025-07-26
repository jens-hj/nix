{pkgs, ...}: {
  home.stateVersion = "24.05";

  catppuccin.flavor = "mocha";
  catppuccin.enable = true;

  nixpkgs.config.allowUnfree = true;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    aichat
    mcrcon
    typst
    typstfmt
    just
    pixi
    pgweb
    dconf
    pre-commit
    comma
    tokei
    ripgrep
    ripgrep-all
    sqlite
    tealdeer
    alejandra
    difftastic
    nix-prefetch-github
    nixfmt-classic
    k9s
    monocraft
  ];

  # Enable the custom base configuration from ./../../modules/default.nix
  base.enable = true;

  programs = {
    # Enable home-manager itself
    home-manager.enable = true;
    # Other
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
