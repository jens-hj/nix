{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  # home.username = "jens";
  # home.homeDirectory = "/home/jens";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home = {
    stateVersion = "24.05";
    # version = {
    #   release = "24.05";
    #   format = "24.05";
    # };
  };

  catppuccin.flavor = "mocha";
  catppuccin.enable = true;

  nixpkgs.config.allowUnfree = true;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    dconf
    dust
    grc
    pre-commit
    comma
    tokei
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
    wget
    curl
    alejandra
    difftastic
    nix-prefetch-github
    nixfmt-classic
    k9s
  ];

  programs = {
    helix = {
      enable = true;
      settings = {
        # theme = "catppuccin_frappe";
        editor.cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
      };
      languages.language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "${pkgs.nixfmt-classic}/bin/nixfmt";
        }
        { name = "kdl"; }
      ];
      defaultEditor = true;
    };
    fish = {
      enable = true;
      shellAbbrs = {
        nixb = "sudo nixos-rebuild switch --flake /home/jens/nixos#default";
        rf = "exec fish";
        rfc = "clear && exec fish";
        dr = "darwin-rebuild switch --flake ~/repos/nix/#macbook";
        obs =
          "pushd ~/repos/notes; git status; git add .; gstatus; git commit --message 'commit from abbr'; gstatus; git push; popd;";
      };
      shellAliases = {
        space = "duf --hide-fs squashfs";
        ls = "eza --icons --group-directories-first --classify --grid";
        ll =
          "eza --icons --group-directories-first --classify --long --header --git";
      };
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

        eval "$(/opt/homebrew/bin/brew shellenv)"

        bind \t super-tab

        if not set -q ZELLIJ
            zellij
        end
      '';
      shellInit = ''
        set --universal git_fish_git_status_command gstatus
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
          name = "autols";
          src = pkgs.fetchFromGitHub {
            owner = "kpbaks";
            repo = "autols.fish";
            rev = "fe2693e80558550e0d995856332b280eb86fde19";
            sha256 = "sha256-EPgvY8gozMzai0qeDH2dvB4tVvzVqfEtPewgXH6SPGs=";
          };
        }
        {
          name = "ctrl-z";
          src = pkgs.fetchFromGitHub {
            owner = "kpbaks";
            repo = "ctrl-z.fish";
            rev = "689d60cb9706d2a19cb65286c2dea488b3293807";
            sha256 = "sha256-OaCMGsIP6wsbzgCNqQR1FOERL+k1ShAjOOg3T9Wln3k=";
          };
        }
        {
          name = "typst";
          src = pkgs.fetchFromGitHub {
            owner = "kpbaks";
            repo = "typst.fish";
            rev = "2d83f6a668a2be4eb00bf45b453c6e360ab5cb86";
            sha256 = "sha256-pYbDIM/+jUTQB8L6jRBSAflNz5l3NwhwRc7SZXr26r0=";
          };
        }
        {
          name = "git";
          src = pkgs.fetchFromGitHub {
            owner = "kpbaks";
            repo = "git.fish";
            rev = "07fe31960a9f6bcf735aba1bb60cb6b517f2c707";
            sha256 = "sha256-uX8s0D4/a0hiuB84E1RDVvah2nnuZL44ykB6wMiIEO4=";
          };
        }
        {
          name = "rust";
          src = pkgs.fetchFromGitHub {
            owner = "kpbaks";
            repo = "rust.fish";
            rev = "16261ed8c2c987c32d6a7d2135554862f2279843";
            sha256 = "sha256-0vOTfAc2uiPQwEwp4hsVhxETZn+wrEmtojzamuLoCX4=";
          };
        }
        {
          name = "border";
          src = pkgs.fetchFromGitHub {
            owner = "kpbaks";
            repo = "border.fish";
            rev = "a16e8e611420b24a2c06d71ffe80c0f8f03514ef";
            sha256 = "sha256-X4Viw9JcLDDTFepaTE2jq09hQCJlo0Nlqa5ga/ygwdA=";
          };
        }
        {
          name = "what-changed";
          src = pkgs.fetchFromGitHub {
            owner = "kpbaks";
            repo = "what-changed.fish";
            rev = "5c61537d5718a4b7a4c9ef903f7f458205b6fe9c";
            sha256 = "sha256-zriK/H/EymSp5dhcn4nX1sZ9qce+v1Q6e8O/B7n21CM=";
          };
        }
        {
          name = "peopletime";
          src = pkgs.fetchFromGitHub {
            owner = "kpbaks";
            repo = "peopletime.fish";
            rev = "d1239e3945163051e34683b48b93b63edc71bd88";
            sha256 = "sha256-J1L4v4/PV3kppfs/prCV1dVN2UW8l2I5Vw+RsijoyEk=";
          };
        }
      ];
    };
    kitty = {
      enable = true;
      settings = {
        font_size = 14;
        confirm_os_window_close = 0;
        tab_bar_style = "hidden";
        hide_window_decorations = "yes";
        window_padding_width = 0;
        window_margin_width = 0;
      };
    };

    # zellij = {
    #   enable = true;
    #   enableFishIntegration = true;
    # };

    git = {
      enable = true;
      userName = "Jens";
      userEmail = "jens.jens@live.dk";
      extraConfig = { diff.external = "difft"; };
    };

    direnv.enable = true;
    fzf.enable = true;
    ssh.enable = true;
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
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
      sha256 = "sha256-OSg7Q1AWKW32Y9sHWJbWOXWF1YI5mt0N4Vsa2fcvuNg=";
    };
    ".config/zellij/plugins/room.wasm".source = pkgs.fetchurl {
      url = "https://github.com/rvcas/room/releases/latest/download/room.wasm";
      sha256 = "sha256-t6GPP7OOztf6XtBgzhLF+edUU294twnu0y5uufXwrkw=";
    };
    ".config/zellij/plugins/zellij_forgot.wasm".source = pkgs.fetchurl {
      url =
        "https://github.com/karimould/zellij-forgot/releases/latest/download/zellij_forgot.wasm";
      sha256 = "sha256-kBGZG+I9PMKhXtyAy6XRW4Sqht0/RCDcv86p0WjxvN8=";
    };
    ".config/zellij/config.kdl".text = ''
        pane_frames false
        session_serialization false
        copy_on_select true
        on_force_close "quit"

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

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/jens/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    CARGO_HOME = "/Users/jens/.cargo";
    COLORTERM = "truecolor";
    fish_term24bit = "1";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
