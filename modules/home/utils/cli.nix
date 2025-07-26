{
  pkgs,
  config,
  lib,
  ...
}: {
  options = {
    utils.cli.enable = lib.mkEnableOption "enable baseline cli utils packages";
  };

  config = lib.mkIf config.utils.cli.enable {
    home.packages = with pkgs; [
      croc
      dust
      bat
      zip
      unzip
      duf
      wget
      curl
    ];
  };
}
