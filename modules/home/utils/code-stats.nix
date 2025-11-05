{ config, lib, ... }:
{
  options = {
    utils.code-stats.enable = lib.mkEnableOption "enable code-stats api";
  };

  config = lib.mkIf config.utils.code-stats.enable {
    home.file = {
      "./.config/code-stats/config.toml".text = ''
        api_token = ""
      '';
    };
  };
}
