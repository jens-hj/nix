{
  config,
  lib,
  pkgs,
  ...
}:
let
  # systemd-oomd was killing the whole ghostty surface cgroup (shell + codex +
  # children) under memory pressure, which reads as "ghostty crashed". Sample
  # the surface cgroups so a future blowup names the process responsible.
  memwatch = pkgs.writeShellApplication {
    name = "ghostty-memwatch";
    runtimeInputs = with pkgs; [ coreutils gawk ];
    text = ''
      log="''${XDG_STATE_HOME:-$HOME/.local/state}/ghostty-memwatch.log"
      threshold_kb=$((3 * 1024 * 1024)) # detail-log above 3 GiB
      appslice=/sys/fs/cgroup/user.slice/user-$(id -u).slice/user@$(id -u).service/app.slice
      while :; do
        for cg in "$appslice"/app-ghostty-surface-transient-*.scope; do
          [ -d "$cg" ] || continue
          cur=$(cat "$cg/memory.current" 2>/dev/null) || continue
          cur_kb=$((cur / 1024))
          [ "$cur_kb" -ge "$threshold_kb" ] || continue
          {
            echo "=== $(date -Is) $(basename "$cg") total=$((cur_kb / 1024))MiB procs=$(wc -l < "$cg/cgroup.procs")"
            while read -r pid; do
              [ -e "/proc/$pid/status" ] || continue
              rss=$(awk '/^VmRSS:/{print $2}' "/proc/$pid/status" 2>/dev/null) || continue
              swp=$(awk '/^VmSwap:/{print $2}' "/proc/$pid/status" 2>/dev/null)
              cmd=$(tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null | cut -c1-120)
              [ -n "$rss" ] && printf '%12s %12s %8s %s\n' "$rss" "''${swp:-0}" "$pid" "$cmd"
            done < "$cg/cgroup.procs" | sort -rn | head -25
          } >> "$log"
        done
        sleep 30
      done
    '';
  };
in
{
  options = {
    terminal.ghostty.enable = lib.mkEnableOption "enable custom configured ghostty";
  };

  config = lib.mkIf config.terminal.ghostty.enable {
    programs.ghostty = {
      enable = true;
      settings = {
        confirm-close-surface = "false";
        window-decoration = "none";
        # font = "ZedMono NFM";
      };
    };

    # Exclude ghostty and its surfaces from systemd-oomd kill candidates, so a
    # long-lived TUI session is not culled under pressure. This must be `omit`,
    # not `avoid`: `avoid` only deprioritises against *other* candidates, and
    # the surface scope is routinely the sole candidate oomd considers, so it
    # gets killed anyway. `omit` drops it from the candidate list entirely.
    # The trailing-dash names are systemd prefix drop-ins: they match every
    # transient scope sharing that prefix.
    xdg.configFile = lib.genAttrs [
      "systemd/user/app-ghostty-surface-transient-.scope.d/50-oomd-omit.conf"
      "systemd/user/app-niri-ghostty-.scope.d/50-oomd-omit.conf"
    ] (_: { text = "[Scope]\nManagedOOMPreference=omit\n"; });

    systemd.user.services.ghostty-memwatch = {
      Unit.Description = "Sample ghostty surface cgroup memory usage";
      Service = {
        ExecStart = lib.getExe memwatch;
        Restart = "on-failure";
        Nice = 10;
        ManagedOOMPreference = "omit";
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}
