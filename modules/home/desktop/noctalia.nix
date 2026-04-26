{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: {
  options = {
    desktop.noctalia.enable = lib.mkEnableOption "Enable noctalia shell";
  };

  config = lib.mkIf config.desktop.noctalia.enable {
    home.packages = with pkgs; [
      ddcutil
      imagemagick
      python3
      git
      brightnessctl
      cliphist
    ];
    programs = {
      cava.enable = true;
      noctalia-shell = {
        enable = true;
        systemd.enable = true;
        package =
          inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default.override
          {calendarSupport = true;};
        settings = {
          settingsVersion = 46;
          bar = {
            barType = "framed";
            position = "left";
            density = "comfortable";
            # backgroundOpacity = lib.mkForce 0.8;
            # useSeparateOpacity = true;
            frameRadius = 24;
            frameThickness = 8;
          };
          general = {
            showScreenCorners = true;
            forceBlackScreenCorners = true;
            enableShadows = false;
            screenRadiusRatio = 1.5;
          };
          location = {
            name = "Risskov";
            showWeekNumberInCalendar = true;
            firstDayOfWeek = 1;
          };
          systemMonitor = {
            enableDgpuMonitoring = true;
          };
          brightness = {
            enableDdcSupport = true;
          };
          sessionMenu = {
            enableCountdown = false;
            showHeader = false;
            largeButtonsStyle = true;
          };
          osd = {
            location = "top_left";
          };
          dock.enabled = false;
          network.wifiEnabled = false;
          notifications.enabled = false;
        };
      };
      quickshell = {
        enable = true;
      };
    };
    home.file.".cache/noctalia/wallpapers.json" = {
      text = builtins.toJSON {
        defaultWallpaper = "${config.home.homeDirectory}/Pictures/Wallpapers/wallpaper.webp";
      };
    };
  };
}
