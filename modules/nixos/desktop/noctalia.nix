{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    desktop.noctalia.enable = lib.mkEnableOption "Enable noctalia shell";
  };

  config = lib.mkIf config.desktop.noctalia.enable {
    boot.kernelModules = ["i2c-dev" "ddcci" "ddcci_backlight"];
    services = {
      gnome = {
        evolution-data-server.enable = true;
        gnome-online-accounts.enable = true;
      };
      accounts-daemon.enable = true;
    };

    environment.systemPackages = with pkgs; [
      gnome-online-accounts
      gnome-control-center
      gnome-online-accounts-gtk
    ];
  };
}
