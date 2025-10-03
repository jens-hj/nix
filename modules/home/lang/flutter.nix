{
  pkgs,
  config,
  lib,
  ...
}: {
  options = {
    lang.flutter.enable = lib.mkEnableOption "flutter";
  };

  config = lib.mkIf config.lang.flutter.enable {
    home.packages = with pkgs; [
      flutter
      cocoapods
    ];
  };
}
