{
  inputs,
  pkgs,
  lib,
  ...
}:
{

  home.username = "j";
  home.homeDirectory = "/home/j";

  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    mcrcon
    k9s
    just
    pgweb
    telegram-desktop
    signal-desktop
    yubioath-flutter
    bitwarden-desktop
    appimage-run
    # inputs.awww.packages.${pkgs.system}.awww
    bluetuith
    p7zip
    swaybg
    gtk3
    webkitgtk_4_1
    libusb1
    keymapp
    wiremix
    winetricks
  ];

  # Enable the custom base configuration from ./../../modules/default.nix
  base.enable = true;
  shell.fish.autoStart.zellij.enable = lib.mkForce false;
  terminal.ghostty.enable = lib.mkForce true;
  typesetters.typst.enable = lib.mkForce true;
  utils.cli.profile = lib.mkForce "extended";
  editor.zed.enable = lib.mkForce true;
  editor.vscode.enable = lib.mkForce true;

  # games.enable = true;

  desktop.enable = true;

  programs = {
    firefox = {
      enable = true;
      profiles.default.extensions.force = true;
    };
    # zen-browser = {
    #   enable = true;
    #   policies = { DisableTelemtry = true; };
    # };
    ghostty.settings = {
      font-size = 18;
    };
    fish.shellAliases = {
      zed = "zeditor";
    };
  };

  services = {
    vicinae = {
      enable = true;
      autoStart = true;
    };
    # hyprpaper = {
    #   enable = true;
    #   # preload = [ "~/Pictures/Wallpapers/wallpaper.png" ];
    #   # wallpaper = [ "~/Pictures/Wallpapers/wallpaper.png" ];
    # };
    # swaybg.enable = true;
    flameshot = {
      enable = true;
      settings = {
        General = {
          useGrimAdapter = true;
          disabledTrayIcon = true;
          showStartupLaunchMessage = false;
        };
      };
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      # xdg-desktop-portal-gtk
      # xdg-desktop-portal-wlr
      xdg-desktop-portal-gnome
    ];
    config.common.default = "gnome";
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/wm/keybindings" = {
        # Set Alt+Tab to switch windows instead of applications
        switch-applications = [ ];
        switch-windows = [ "<Alt>Tab" ];

        switch-applications-backward = [ ];
        switch-windows-backward = [ "<Shift><Alt>Tab" ];
      };

      # Optional: allow switching windows across workspaces
      "org/gnome/shell/window-switcher" = {
        current-workspace-only = false;
      };
    };
  };

  home.sessionVariables = {
    PATH = "$PATH:~/.cargo/bin";
    MCRCON_HOST = "localhost";
    MCRCON_PASS = "7568";
    COLORTERM = "truecolor";
    fish_term24bit = "1";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    TERM = "xterm-256color";
    XDG_DATA_DIRS = "$XDG_DATA_DIRS:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share";
  };
}
