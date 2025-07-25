{ pkgs, config, lib, ... }: {
  options = {
    ghostty.enable = lib.mkEnableOption "enable custom configured ghostty";
  };

  config = lib.mkIf config.ghostty.enable {
    programs.ghostty.enable = true;
    # home.packages = [ pkgs.ghostty ];
  };
}
