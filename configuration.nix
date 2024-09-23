# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, ... }:
let
  # unstableTarball = builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in
{
  imports = [
    # (import "${unstableTarball}/nixos")
    # include NixOS-WSL modules
    <nixos-wsl/modules>
    # include home-manager modules
    # <home-manager/nixos>
    (import "${home-manager}/nixos")
  ];

  users.users.nixos = { shell = pkgs.fish; };

  wsl.enable = true;
  wsl.defaultUser = "nixos";

  programs = {
    fish.enable = true;
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        # Add any missing dynamic libraries for unpackaged programs
        # here, NOT in environment.systemPackages
      ];
    };
  };

  nix = {
    # package = pkgs.nixFlakes;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      substituters =
        [ "https://cache.nixos.org" "https://nix-community.cachix.org" ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      trusted-substituters = [ "https://cache.nixos.org" ];
    };
  };

  # Create symlink from /mnt/c/Users/<myuser>/repos to ~/repos
  systemd.tmpfiles.rules =
    [ "L /home/nixos/clones - - - - /mnt/c/Users/jensj/source/repos" ];

  # home-manager stuff
  home-manager.users.nixos = { pkgs, ... }: {
    home.packages = with pkgs; [
      # devenv
      evince
      grc
      pastel
      fd
      dust
      pre-commit
      comma
      rustup
      ripgrep
      ripgrep-all
      tree
      sqlite
      bat
      eza
      tealdeer
      zip
      unzip
      duf
      upower
      wget
      curl
      nix-prefetch-github
      alejandra
    ];

    programs = {
      helix = {
        enable = true;
        settings = {
          theme = "catppuccin_frappe";
          editor.cursor-shape = {
            normal = "block";
            insert = "bar";
            select = "underline";
          };
        };
        languages.language = [{
          name = "nix";
          auto-format = true;
          formatter.command = "${pkgs.nixfmt-classic}/bin/nixfmt";
        }];
        defaultEditor = true;
      };
      fish = {
        enable = true;
        interactiveShellInit = ''
          set fish_greeting # Disable greeting

          function super-tab
              commandline --paging-mode && down-or-search && return

              set -l buf (commandline)
              if string match -q -r '^\s*$' -- $buf
                  repos cd
              else
                  commandline -f complete
                  commandline -f pager-toggle-search
              end
              commandline -f repaint
          end

          bind \t super-tab
        '';
        shellInit = ''
          set --universal git_fish_git_status_command gstatus

          abbr -a rf 'exec fish'
          abbr -a rfc 'clear && exec fish'
          abbr --position anywhere --set-cursor -a wind '/mnt/c/Users/jensj/%'
          abbr -a PS 'PowerShell.exe'

          alias space 'duf --hide-fs squashfs'
          alias power 'upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E "state:|time to full:|percentage:|energy-rate:|energy:|energy-full:|charge-cycles:|time to empty:"'
          alias cpower 'upower -i /org/freedesktop/UPower/devices/battery_ps_controller_battery_58o10o31o1eo60od3 | grep -E "state:|time to full:|percentage:|energy-rate:|energy:|energy-full:|charge-cycles:|time to empty:"'

          alias ls 'eza --icons --group-directories-first --classify --grid'
          alias ll 'eza --icons --group-directories-first --classify --long --header --git'

          set -x CARGO_HOME ~/.cargo
          set -x COLORTERM truecolor
          set -x fish_term24bit 1
        '';
        plugins = [
          # Enable a plugin (here grc for colorized command output) from nixpkgs
          {
            name = "grc";
            src = pkgs.fishPlugins.grc.src;
          }
          {
            name = "z";
            src = pkgs.fishPlugins.z.src;
          }
          {
            name = "sponge";
            src = pkgs.fishPlugins.sponge.src;
          }
          {
            name = "puffer";
            src = pkgs.fishPlugins.puffer.src;
          }
          {
            name = "pure";
            src = pkgs.fishPlugins.pure.src;
          }
          {
            name = "fzf-fish";
            src = pkgs.fishPlugins.fzf-fish.src;
          }
          {
            name = "colored-man-pages";
            src = pkgs.fishPlugins.colored-man-pages.src;
          }
          {
            name = "colored-man-pages";
            src = pkgs.fishPlugins.colored-man-pages.src;
          }
          # kpbaks
          {
            name = "typst";
            src = builtins.fetchTarball "https://github.com/kpbaks/typst.fish/archive/master.tar.gz";
          }
          {
            name = "git";
            src = builtins.fetchTarball "https://github.com/kpbaks/git.fish/archive/master.tar.gz";
          }
          {
            name = "countdown";
            src = builtins.fetchTarball "https://github.com/kpbaks/countdown.fish/archive/master.tar.gz";
          }
          {
            name = "autols";
            src = builtins.fetchTarball "https://github.com/kpbaks/autols.fish/archive/master.tar.gz";
          }
          {
            name = "ctrl-z";
            src = builtins.fetchTarball "https://github.com/kpbaks/ctrl-z.fish/archive/master.tar.gz";
          }
          {
            name = "rust";
            src = builtins.fetchTarball "https://github.com/kpbaks/rust.fish/archive/master.tar.gz";
          }
          {
            name = "border";
            src = builtins.fetchTarball "https://github.com/kpbaks/border.fish/archive/master.tar.gz";
          }
          {
            name = "what-changed";
            src = builtins.fetchTarball "https://github.com/kpbaks/what-changed.fish/archive/master.tar.gz";
          }
          {
            name = "peopletime";
            src = builtins.fetchTarball "https://github.com/kpbaks/peopletime.fish/archive/master.tar.gz";
          }
          {
            name = "zellij";
            src = builtins.fetchTarball "https://github.com/kpbaks/zellij.fish/archive/master.tar.gz";
          }
        ];
      };

      zellij = {
        enable = true;
        enableFishIntegration = true;
      };

      git = {
        enable = true;
        userName = "Jens";
        userEmail = "jens.jens@live.dk";
      };

      direnv.enable = true;
      fzf.enable = true;
      ssh.enable = true;
    };

    # Define the custom layout and plugin file
    home.file = {
      ".config/zellij/layouts/custom-layout.kdl".text = ''
        layout {
          default_tab_template {
            children
            pane size=1 borderless=true {
              plugin location="file:~/.config/zellij/plugins/zjstatus.wasm" {
                format_left  "{mode} #[fg=cyan,bold]{session} {tabs}"
                format_right "{command_git_branch} {datetime}"
                format_space ""

                border_enabled  "false"
                border_char     "─"
                border_format   "#[fg=white]{char}"
                border_position "top"

                hide_frame_for_single_pane "true"

                mode_normal  "#[bg=cyan] "
                mode_tmux    "#[bg=red] "

                tab_normal   "#[fg=white] {name} "
                tab_active   "#[fg=yellow,bold,italic] {name} "

                command_git_branch_command   "git rev-parse --abbrev-ref HEAD"
                command_git_branch_format    "#[fg=magenta] {stdout} "
                command_git_branch_interval  "10"

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
        url =
          "https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm";
        sha256 = "sha256-IgTfSl24Eap+0zhfiwTvmdVy/dryPxfEF7LhVNVXe+U=";
      };
      ".config/zellij/plugins/room.wasm".source = pkgs.fetchurl {
        url =
          "https://github.com/rvcas/room/releases/latest/download/room.wasm";
        sha256 = "sha256-wCGnvFaoaoyH6QFkIqaDj0j0lGe1DOAX4ZmUQOyT/eY=";
      };
      ".config/zellij/plugins/zellij_forgot.wasm".source = pkgs.fetchurl {
        url =
          "https://github.com/karimould/zellij-forgot/releases/latest/download/zellij_forgot.wasm";
        sha256 = "sha256-WdPKHrCtmg0dv446f8KkHNnAk/GKXtufJfCZyLXf7cM=";
      };
      ".config/zellij/config.kdl".text = ''
          pane_frames false
          session_serialization false
          copy_on_select true

          default_layout "custom-layout"

          ui {
              pane_frames {
                  rounded_corners true
              }
          }

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

    fonts.fontconfig.enable = true;

    home.stateVersion =
      "23.11"; # KEEP THIS, read comment for system.stateVersion
  };

  environment.systemPackages = with pkgs; [ helix git ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
