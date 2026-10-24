{
  config,
  lib,
  ...
}: {
  options = {
    srv.zigbee.enable = lib.mkEnableOption "enables Zigbee and Home Assistant";
  };

  config = lib.mkIf config.srv.zigbee.enable {
    services.mosquitto = {
      enable = true;
      listeners = [
        {
          acl = ["pattern readwrite #"];
          omitPasswordAuth = true;
          settings.allow_anonymous = true;
        }
      ];
    };

    services.zigbee2mqtt = {
      enable = true;
      settings = {
        homeassistant = {
          enabled = true;
        };
        permit_join = true;
        mqtt = {
          server = "mqtt://localhost:1883";
        };
        serial = {
          port = "/dev/serial/by-id/usb-Itead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_V2_1ce401eb8212ef11b26c6db8bf9df066-if00-port0";
          adapter = "ember";
        };
        frontend = {
          port = 8080;
        };
        advanced = {
          log_level = "info";
        };
      };
    };

    # Home Assistant
    services.home-assistant = {
      enable = true;
      extraComponents = [
        "analytics"
        "google_translate"
        "met"
        "radio_browser"
        "shopping_list"
        "isal"
        "mqtt"
      ];
      config = {
        default_config = {};
        homeassistant = {
          name = "Home";
          unit_system = "metric";
          time_zone = "Europe/Copenhagen";
        };
      };
    };

    networking.firewall.allowedTCPPorts = [8080 8123];
  };
}
