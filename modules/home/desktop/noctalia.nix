{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: let
  noctaliaPluginsUrl = "https://github.com/noctalia-dev/noctalia-plugins";

  enabledPlugins = [
    "privacy-indicator"
    "usb-drive-manager"
    "show-keys"
  ];

  pluginFiles = builtins.listToAttrs (map (id: {
      name = "noctalia/plugins/${id}";
      value = {
        source = "${inputs.noctalia-plugins}/${id}";
        recursive = true;
      };
    })
    enabledPlugins);

  pluginStates = builtins.listToAttrs (map (id: {
      name = id;
      value = {
        enabled = true;
        sourceUrl = noctaliaPluginsUrl;
      };
    })
    enabledPlugins);
in {
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
    xdg.configFile = pluginFiles;
    programs = {
      cava.enable = true;
      noctalia-shell = {
        enable = true;
        package =
          (inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default.override
            {calendarSupport = true;})
          .overrideAttrs (old: {
            postPatch =
              (old.postPatch or "")
              + ''
                # Force fresh object reference so QML's autoConnectSettingsChanged
                # signal fires and per-device Auto-connect checkbox updates live.
                substituteInPlace Services/Networking/BluetoothService.qml \
                  --replace-fail \
                    'let settings = cacheAdapter.autoConnectSettings || ({});' \
                    'let settings = Object.assign({}, cacheAdapter.autoConnectSettings || {});'
              '';
          });
        plugins = {
          version = 2;
          sources = [
            {
              name = "Noctalia Plugins";
              url = noctaliaPluginsUrl;
              enabled = true;
            }
          ];
          states = pluginStates;
        };
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
            widgets = {
              left = [
                {id = "Clock";}
                {id = "SystemMonitor";}
                {id = "plugin:privacy-indicator";}
                {id = "ActiveWindow";}
                {id = "MediaMini";}
              ];
              center = [
                {id = "Workspace";}
              ];
              right = [
                {id = "plugin:usb-drive-manager";}
                {id = "Tray";}
                {id = "Battery";}
                {id = "Volume";}
                {
                  id = "Brightness";
                  applyToAllMonitors = true;
                }
                {id = "Bluetooth";}
                {id = "ControlCenter";}
              ];
            };
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
