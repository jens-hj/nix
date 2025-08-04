{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    typesetters.typst.enable = lib.mkEnableOption "enable custom theming";
  };

  config = lib.mkIf config.typesetters.typst.enable {
    home.packages = with pkgs; [
      typst
      typstfmt
    ];
  };
}
