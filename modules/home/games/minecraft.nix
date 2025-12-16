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
      modrinth-app
    ];
  };
}
