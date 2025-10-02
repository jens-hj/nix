{ pkgs, config, lib, ... }: {
  options = {
    visuals.fonts.enable = lib.mkEnableOption "enable custom fonts";
  };

  config = lib.mkIf config.visuals.fonts.enable {
    home.packages = with pkgs; [
      nerd-fonts.zed-mono
      nerd-fonts.jetbrains-mono
      monocraft
    ];

    fonts.fontconfig.enable = true;
  };
}
