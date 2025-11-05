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
    # home.file.".config/themes/catppuccin-mocha.taml".text =
    #   ''${inputs.nix-colors.lib.schemeToYAML inputs.nix-colors.colorSchemes.catppuccin-mocha}'';
    stylix = {
      enable = true;
      autoEnable = true;
      targets.zed.enable = false;
      image = ./wallpaper.png;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
      polarity = "dark";
    };
    # specialisation.light.configuration.stylix = {
    #   base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-latte.yaml";
    #   polarity = "light";
    # };
    # catppuccin.flavor = "mocha";
    # catppuccin.enable = true;
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
