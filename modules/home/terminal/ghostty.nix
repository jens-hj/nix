{
  config,
  lib,
  ...
}: {
  options = {
    terminal.ghostty.enable = lib.mkEnableOption "enable custom configured ghostty";
  };

  config = lib.mkIf config.terminal.ghostty.enable {
    programs.ghostty.enable = true;
  };
}
