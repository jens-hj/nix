# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, ... }:

{
  imports = [
    # include NixOS-WSL modules
    <nixos-wsl/modules>
    # include home-manager modules
    <home-manager/nixos>
  ];

  users.users.nixos = { shell = pkgs.fish; };

  wsl.enable = true;
  wsl.defaultUser = "nixos";

  programs.fish.enable = true;

  nix = {
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
    [ "L /home/nixos/repos - - - - /mnt/c/Users/jensj/source/repos" ];

  # home-manager stuff
  home-manager.users.nixos = { pkgs, ... }: {
    home.packages = with pkgs; [
      # devenv
      evince
      grc
      pastel
      fd
      # dust
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
      # zellij
      # font-awesome
      # (nerdfonts.override { fonts = ["JetBrainsMono" "Iosevka"]; })
      wget
      curl
      nix-prefetch-github
      alejandra
    ];

    programs = {
      helix = {
        enable = true;
        settings = {
          theme = "catppuccin_macchiato";
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
      };
      fish = {
        enable = true;
        interactiveShellInit = ''
          set fish_greeting # Disable greeting

          # set -x COUNTDOWN_COLORS (pastel gradient '#8aadf4' '#c6a0f6' '#ed8796'  -s HSL -n 100 | pastel format hex)
          # countdown -s (date --date '2024-01-29' +%s) -e (date --date '2024-6-04 12:00' +%s) -t "Master Thesis Hand-in Deadline"

          if not set -q ZELLIJ
              zellij
          end

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
          set -gx EDITOR hx
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
          # { name = "hydro"; src = pkgs.fishPlugins.hydro.src; }
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
            src = builtins.fetchGit {
              url = "https://github.com/kpbaks/typst.fish.git";
            };
          }
          {
            name = "git";
            src = builtins.fetchGit {
              url = "https://github.com/kpbaks/git.fish.git";
            };
          }
          {
            name = "countdown";
            src = builtins.fetchGit {
              url = "https://github.com/kpbaks/countdown.fish.git";
            };
          }
          {
            name = "autols";
            src = builtins.fetchGit {
              url = "https://github.com/kpbaks/autols.fish.git";
            };
          }
          {
            name = "ctrl-z";
            src = builtins.fetchGit {
              url = "https://github.com/kpbaks/ctrl-z.fish.git";
            };
          }
          {
            name = "rust";
            src = builtins.fetchGit {
              url = "https://github.com/kpbaks/rust.fish.git";
            };
          }
          {
            name = "border";
            src = builtins.fetchGit {
              url = "https://github.com/kpbaks/border.fish.git";
            };
          }
          {
            name = "what-changed";
            src = builtins.fetchGit {
              url = "https://github.com/kpbaks/what-changed.fish.git";
            };
          }
          {
            name = "peopletime";
            src = builtins.fetchGit {
              url = "https://github.com/kpbaks/peopletime.fish.git";
            };
          }
          {
            name = "zellij";
            src = builtins.fetchGit {
              url = "https://github.com/kpbaks/zellij.fish.git";
            };
          }
        ];
      };

      zellij = {
        enable = true;
        settings = {
          ui.pane_frames.rounded_corners = true;
          theme = "catppuccin-frappe";
          default_layout = "compact";
        };
      };

      git = {
        enable = true;
        userName = "Jens";
        userEmail = "jens.jens@live.dk";
        extraConfig = { credential.helper = "store"; };
      };

      direnv.enable = true;
      fzf.enable = true;
      ssh.enable = true;
    };

    fonts.fontconfig.enable = true;

    home.stateVersion =
      "23.11"; # KEEP THIS, read comment for system.stateVersion
  };

  environment.systemPackages = with pkgs; [ helix ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
