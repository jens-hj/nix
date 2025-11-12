{
  config,
  lib,
  ...
}:
{
  options = {
    desktop.waybar.enable = lib.mkEnableOption "Enable waybar";
  };

  config = lib.mkIf config.desktop.waybar.enable {
    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          position = "top";
          spacing = 10;
          modules-left = [
            "niri/workspaces"
          ];
          modules-center = [
            "niri/window"
          ];
          modules-right = [
            "backlight/slider"
            "clock"
          ];
          "backlight/slider" = {
            min = 0;
            max = 100;
            orientation = "vertical";
          };
          clock = {
            # tooltip-format = "<tt><big>{:%T / %d-%m-%Y / %A W%U / %B}</big>\n\n<small>{calendar}</small></tt>";
            tooltip-format = "<tt><small>{calendar}</small></tt>";
            format = "{:%T}";
            format-alt = "{:%T / %d-%m-%Y / %A W%U / %B}";
            interval = 1;
            calendar = {
              mode = "year";
              mode-mon-col = 3;
              weeks-pos = "right";
              on-scroll = 1;
              format = {
                months = "<span color='#b4befe'>{}</span>";
                days = "<span color='#cdd6f4'>{}</span>";
                weekdays = "<span color='#cba6f7'>{}</span>";
                weeks = "<span color='#89b4fa'>{}</span>";
                today = "<span color='#a6e3a1'><b>{}</b></span>";
              };
            };
            actions = {
              on-click-right = "mode";
              on-scroll-up = [
                "tz_up"
                "shift_up"
              ];
              on-scroll-down = [
                "tz_down"
                "shift_down"
              ];
            };
          };
        };
      };
      style = ''
        #backlight-slider slider {
          min-height: 0px;
          min-width: 0px;
        }
      '';
    };
  };
}
