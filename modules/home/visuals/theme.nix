{
  config,
  lib,
  ...
}: {
  options = {
    visuals.theme.enable = lib.mkEnableOption "enable custom theming";
  };

  config = lib.mkIf config.visuals.theme.enable {
    catppuccin.flavor = "mocha";
    catppuccin.enable = true;
  };
}
