{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    games.minecraft.enable = lib.mkEnableOption "Enable minecraft";
  };

  config = lib.mkIf config.games.minecraft.enable {
    home.packages = with pkgs; [
      (modrinth-app.overrideAttrs (oldAttrs: {
        buildCommand = ''
          gappsWrapperArgs+=(
             --set GDK_BACKEND x11
          )
        ''
        + oldAttrs.buildCommand;
      }))
    ];
  };
}
