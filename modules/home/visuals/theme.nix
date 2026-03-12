{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    visuals.theme.enable = lib.mkEnableOption "enable custom theming";
    visuals.wallpaper.enable = lib.mkEnableOption "enable wallpaper";
  };

  config = lib.mkIf config.visuals.theme.enable (
    lib.mkMerge [
      (lib.mkIf config.visuals.wallpaper.enable {
        stylix.image = ./wallpaper.png;
      })
      {
        stylix = {
          enable = true;
          autoEnable = true;
          targets = {
            zed.enable = false;
            vscode.enable = false;
            vesktop.enable = false;
            firefox.profileNames = ["default"];
            zen-browser.profileNames = ["default"];
          };

          base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
          polarity = "dark";

          fonts = {
            monospace = {
              package = pkgs.nerd-fonts.zed-mono;
              name = "ZedMono NFM";
            };
          };
        };

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
          dconf
          # … other extensions
        ];

        dconf.enable = lib.mkForce true;
        dconf.settings = {
          "org/gnome/shell" = {
            enabled-extensions = [
              "user-theme@gnome-shell-extensions.gcampax.github.com"
            ];
          };
        };
      }
    ]
  );
}
