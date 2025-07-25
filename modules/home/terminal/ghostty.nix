{ pkgs, config, lib, ... }: {
  options = {
    ghostty.enable = lib.mkEnableOption "enable custom configurate ghostty";
  };

  config =
    lib.mkIf config.ghostty.enable { home.packages = with pkgs; [ ghostty ]; };
}
