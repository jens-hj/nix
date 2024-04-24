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

  # nix = {
  #   settings = {
  #     experimental-features = [ "nix-command" "flakes" ];
  #   };
  # };

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
          formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
        }];
      };
      fish = {
        enable = true;
        interactiveShellInit = ''
          set fish_greeting # Disable greeting

          set -x COUNTDOWN_COLORS (pastel gradient '#8aadf4' '#c6a0f6' '#ed8796'  -s HSL -n 100 | pastel format hex)
          countdown -s (date --date '2024-01-29' +%s) -e (date --date '2024-6-04 12:00' +%s) -t "Master Thesis Hand-in Deadline"

          if not set -q ZELLIJ
              zellij
          end
        '';
        shellInit = ''
          set -gx EDITOR hx
          set --universal git_fish_git_status_command gstatus

          abbr -a rf 'exec fish'
          abbr -a rfc 'clear && exec fish'
          abbr -a PS 'PowerShell.exe'

          alias space 'duf --hide-fs squashfs'
          alias power 'upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E "state:|time to full:|percentage:|energy-rate:|energy:|energy-full:|charge-cycles:|time to empty:"'
          alias cpower 'upower -i /org/freedesktop/UPower/devices/battery_ps_controller_battery_58o10o31o1eo60od3 | grep -E "state:|time to full:|percentage:|energy-rate:|energy:|energy-full:|charge-cycles:|time to empty:"'

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
            src = pkgs.fetchFromGitHub {
              owner = "kpbaks";
              repo = "typst.fish";
              rev = "25b8ddfe27654d641382f5251807879459bd2d42";
              sha256 = "sha256-vE13aH/Bp3R+43RbiXaoVfrKdrmtFCpQ7IN2i1M6B9M=";
            };
          }
          {
            name = "git";
            src = pkgs.fetchFromGitHub {
              owner = "kpbaks";
              repo = "git.fish";
              rev = "b09c4d467dd22d8cbebb6de68746e295ca3f64a2";
              sha256 = "sha256-iXPGUf6y2/ABGLoGE1ZaxF0oml06TQ68uiiLrIZY+Yk=";
            };
          }
          {
            name = "countdown";
            src = pkgs.fetchFromGitHub {
              owner = "kpbaks";
              repo = "countdown.fish";
              rev = "af93bb541d6b9134aef41e65a311ec41da1a5e5a";
              sha256 = "sha256-EW88pygEshmwoJUo2/TXNsGw4Ynf0xUDjluONq1mmoM=";
            };
          }
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
              rev = "bf597fc4d0187ff9011e3abe4f7932339244c438";
              sha256 = "sha256-vn5tJehcUQIOxgQxX+RFe1XYz6zci3L9xNqA0UBfMYE=";
            };
          }
          {
            name = "rust";
            src = pkgs.fetchFromGitHub {
              owner = "kpbaks";
              repo = "rust.fish";
              rev = "f1caf3b68c2d2aa49132bf1206526612bab538a3";
              sha256 = "sha256-7T3hJuFWP5AJLD2+mdUrYcx7BV5g8YVV60h/9QM5pr4=";
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
          {
            name = "zellij";
            src = pkgs.fetchFromGitHub {
              owner = "kpbaks";
              repo = "zellij.fish";
              rev = "0b2393b48b55a7f3b200b5a12ac0cf26444b7172";
              sha256 = "sha256-Nxo6usCI5tqLJ/CZ1YXtCFJ+piy1DGlzFIi9/HSgDIk=";
            };
          }
        ];
      };

      zellij = {
        enable = true;
        settings = {
          ui.pane_frames.rounded_corners = true;
          theme = "catppuccin-macchiato";
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
