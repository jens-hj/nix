{ pkgs, config, lib, ... }: {
  options = {
    base.enable = lib.mkEnableOption "enable baseline packages";
  };

  config = lib.mkIf config.base.enable {
    home.packages = with pkgs; [
      nil
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
};
