{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    visuals.theme.enable = lib.mkEnableOption "enable custom theming";
  };

  config = lib.mkIf config.visuals.theme.enable {
    stylix = {
      enable = true;
      autoEnable = true;
      targets = {
        zed.enable = false;
        vscode.enable = false;
      };

      image = ./wallpaper.png;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
      polarity = "dark";

      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.zed-mono;
          name = "ZedMono NFM";
        };

        # sizes = {
        #   applications = 20;
        #   terminal = 20;
        # };
      };
    };
    # specialisation.light.configuration.stylix = {
    #   base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-latte.yaml";
    #   polarity = "light";
    # };

    home.pointerCursor = {
      enable = true;
      name = "Posy_Cursor_Black";
      package = pkgs.posy-cursors;
      size = 64;
      gtk.enable = true;
      x11.enable = true;
    };

    home.packages = with pkgs; [
      gnomeExtensions.user-themes
      # … other extensions
    ];

    dconf.enable = true;
    dconf.settings = {
      "org/gnome/shell" = {
        enabled-extensions = [
          "user-theme@gnome-shell-extensions.gcampax.github.com"
        ];
      };
    };
  };
}
