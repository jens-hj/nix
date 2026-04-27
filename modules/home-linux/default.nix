{
  config,
  lib,
  ...
}: {
  imports = [
    ./visuals/theme.nix
    ./desktop/waybar.nix
    ./desktop/noctalia.nix
  ];

  options = {
    desktop.enable = lib.mkEnableOption "enables custom desktop environment";
  };

  config = lib.mkMerge [
    (lib.mkIf config.base.enable {
      visuals.theme.enable = lib.mkDefault true;
    })

    (lib.mkIf config.desktop.enable {
      # desktop.waybar.enable = lib.mkDefault true;
      desktop.noctalia.enable = lib.mkDefault true;
      # TODO: add niri module here
    })
  ];
}
