{ config, lib, ... }:
{
  options = {
    visuals.theme.enable = lib.mkEnableOption "enables system theming with catppuccin";
  };

  config = lib.mkIf config.visuals.theme.enable {
    # stylix.image = ./wallpaper.jpg;
    catppuccin.flavor = "mocha";
    catppuccin.enable = true;
  };
}
