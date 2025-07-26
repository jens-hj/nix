{
  pkgs,
  config,
  lib,
  ...
}: {
  options = {
    base-pkgs.enable = lib.mkEnableOption "enable baseline packages";
  };

  config = lib.mkIf config.base-pkgs.enable {
    home.packages = with pkgs; [
      alejandra
      nil
      nixd
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
