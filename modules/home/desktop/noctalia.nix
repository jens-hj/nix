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
      brightnessctl
    ];
    programs = {
      cava.enable = true;
      noctalia = {
        enable = true;
        package =
          inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs
          (old: {
            # Drop the "°C" suffix from CPU/GPU temperature sysmon widgets so the
            # value fits on the narrow vertical bar. The format string appears
            # twice (CpuTemp, GpuTemp); both are replaced.
            postPatch =
              (old.postPatch or "")
              + ''
                substituteInPlace src/shell/bar/widgets/sysmon_widget.cpp \
                  --replace-fail '"{:.0f}°C"' '"{:.0f}"'
              '';
          });
        # v5 config.toml schema (TOML). Settings can still be tweaked at runtime
        # via the Settings panel; those overrides live in settings.toml.
        settings = {
          shell.screen_corners = {
            enabled = true;
            size = 42;
          };
          shell.panel = {
            open_near_click_control_center = true;
            open_near_click_launcher = true;
            open_near_click_clipboard = true;
            open_near_click_wallpaper = true;
            open_near_click_session = true;
          };

          theme = {
            mode = "dark";
            source = "builtin";
            builtin = "Catppuccin";
          };

          wallpaper = {
            enabled = true;
            directory = "${config.home.homeDirectory}/Pictures/Wallpapers";
            default.path = "${config.home.homeDirectory}/Pictures/Wallpapers/wallpaper.webp";
          };

          location.address = "Risskov";

          system.monitor = {
            enabled = true;
            # gpu_poll_seconds defaults to 0 (disabled), unlike the other
            # metrics — GPU widgets stay empty without this opt-in.
            gpu_poll_seconds = 5.0;
          };
          brightness.enable_ddcutil = true;
          osd.position = "top_left";
          dock.enabled = false;
          notification.enable_daemon = false;

          bar.main = {
            position = "left";
            background_opacity = 0.75;
            capsule = true;
            radius = 24;
            margin_edge = 5;
            margin_ends = 5;
            padding = 4;
            shadow = false;
            start = ["clock" "cpu" "temp" "ram" "gpu" "gpu_temp" "active_window" "media"];
            center = ["workspaces"];
            end = ["tray" "battery" "volume" "brightness" "bluetooth" "control-center"];
          };

          # cpu (cpu_usage), temp (cpu_temp), ram are built-in sysmon aliases;
          # GPU stats need explicit instances. ram defaults to ram_used ("8.2
          # GiB") — switch to ram_pct so the vertical bar shows a bare integer
          # (% is auto-stripped on vertical bars; see displaySysmonLabel).
          widget.ram.stat = "ram_pct";
          widget.gpu = {
            type = "sysmon";
            stat = "gpu_usage";
          };
          widget.gpu_temp = {
            type = "sysmon";
            stat = "gpu_temp";
          };

          widget.tray.drawer = true;
          widget.workspaces = {
            hide_when_empty = true;
            occupied_color = "surface_variant";
            empty_color = "surface_variant";
          };
        };
      };
    };
  };
}
