{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    editor.vis.enable = lib.mkEnableOption "enables vis";
  };

  config = lib.mkIf config.editor.vis.enable {
    home.packages = [pkgs.vis];
  };
}
