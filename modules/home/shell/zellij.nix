{
  pkgs,
  config,
  lib,
  ...
}: {
  options = {
    shell.zellij.enable = lib.mkEnableOption "enable custom configured zellij";
  };

  config = lib.mkIf config.shell.zellij.enable {
    home.packages = with pkgs; [
      zellij
    ];

    # Configuration
    home.file = {
      ".config/zellij/layouts/custom-layout.kdl".text = ''
        layout {
            default_tab_template {
            children
            pane size=1 borderless=true {
                plugin location="file:~/.config/zellij/plugins/zjstatus.wasm" {
                format_left  "{mode} #[fg=cyan,bold]{session} {tabs}"
                format_right "{datetime}"
                format_space ""

                mode_normal  "#[bg=cyan] "
                mode_tmux    "#[bg=red] "

                tab_normal   "#[fg=white] {name} "
                tab_active   "#[fg=yellow,bold,italic] {name} "

                datetime          "#[fg=white,bold] {format} "
                datetime_format   "%A, %d %b %Y %H:%M"
                datetime_timezone "Europe/Berlin"
                }
            }
            }
            tab name="default" focus=true
        }
      '';
      ".config/zellij/plugins/zjstatus.wasm".source = pkgs.fetchurl {
        url = "https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm";
        sha256 = "sha256-3BmCogjCf2aHHmmBFFj7savbFeKGYv3bE2tXXWVkrho=";
      };
      ".config/zellij/plugins/room.wasm".source = pkgs.fetchurl {
        url = "https://github.com/rvcas/room/releases/latest/download/room.wasm";
        sha256 = "sha256-kLSDpAt2JGj7dYYhYFh6BfvtzVwTrcs+0jHwG/nActE=";
      };
      ".config/zellij/plugins/zellij_forgot.wasm".source = pkgs.fetchurl {
        url = "https://github.com/karimould/zellij-forgot/releases/latest/download/zellij_forgot.wasm";
        sha256 = "sha256-MRlBRVGdvcEoaFtFb5cDdDePoZ/J2nQvvkoyG6zkSds=";
      };
      ".config/zellij/config.kdl".text = ''
            session_serialization false
            copy_on_select true
            on_force_close "quit"

            ui {
            pane_frames {
                rounded_corners true
            }
            }

            pane_frames false

            default_layout "custom-layout"

            theme "catppuccin-macchiato"

            keybinds {
            normal {
                bind "Alt q" { GoToTab 1; }
                bind "Alt w" { GoToTab 2; }
                bind "Alt e" { GoToTab 3; }
                bind "Alt r" { GoToTab 4; }
                bind "Alt t" { GoToTab 5; }
                bind "Alt t" { NewTab; }
            }
            shared_except "locked" {
                bind "Ctrl y" {
                    LaunchOrFocusPlugin "file:~/.config/zellij/plugins/room.wasm" {
                        floating true
                        ignore_case true
                    }
                }
            }
            shared_except "locked" {
                bind "Ctrl e" {
                    LaunchOrFocusPlugin "file:~/.config/zellij/plugins/zellij_forgot.wasm" {
                        "lock"                  "ctrl + g"
                        "unlock"                "ctrl + g"
                        "new pane"              "ctrl + p + n"
                        "change focus of pane"  "ctrl + p + arrow key"
                        "close pane"            "ctrl + p + x"
                        "rename pane"           "ctrl + p + c"
                        "toggle fullscreen"     "ctrl + p + f"
                        "toggle floating pane"  "ctrl + p + w"
                        "toggle embed pane"     "ctrl + p + e"
                        "choose right pane"     "ctrl + p + l"
                        "choose left pane"      "ctrl + p + r"
                        "choose upper pane"     "ctrl + p + k"
                        "choose lower pane"     "ctrl + p + j"
                        "new tab"               "ctrl + t + n"
                        "close tab"             "ctrl + t + x"
                        "change focus of tab"   "ctrl + t + arrow key"
                        "rename tab"            "ctrl + t + r"
                        "sync tab"              "ctrl + t + s"
                        "brake pane to new tab" "ctrl + t + b"
                        "brake pane left"       "ctrl + t + ["
                        "brake pane right"      "ctrl + t + ]"
                        "toggle tab"            "ctrl + t + tab"
                        "increase pane size"    "ctrl + n + +"
                        "decrease pane size"    "ctrl + n + -"
                        "increase pane top"     "ctrl + n + k"
                        "increase pane right"   "ctrl + n + l"
                        "increase pane bottom"  "ctrl + n + j"
                        "increase pane left"    "ctrl + n + h"
                        "decrease pane top"     "ctrl + n + K"
                        "decrease pane right"   "ctrl + n + L"
                        "decrease pane bottom"  "ctrl + n + J"
                        "decrease pane left"    "ctrl + n + H"
                        "move pane to top"      "ctrl + h + k"
                        "move pane to right"    "ctrl + h + l"
                        "move pane to bottom"   "ctrl + h + j"
                        "move pane to left"     "ctrl + h + h"
                        "search"                "ctrl + s + s"
                        "go into edit mode"     "ctrl + s + e"
                        "detach session"        "ctrl + o + w"
                        "open session manager"  "ctrl + o + w"
                        "quit zellij"           "ctrl + q"
                        floating true
                    }
                }
            }
        }
      '';
    };
  };
}
