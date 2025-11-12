{
  config,
  lib,
  ...
}:
{
  options = {
    terminal.ghostty.enable = lib.mkEnableOption "enable custom configured ghostty";
  };

  config = lib.mkIf config.terminal.ghostty.enable {
    programs.ghostty = {
      enable = true;
      settings = {
        confirm-close-surface = "false";
        window-decoration = "none";
        # font = "ZedMono NFM";
      };
    };
  };
}
