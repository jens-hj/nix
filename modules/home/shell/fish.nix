{ pkgs, config, lib, ... }: {
  options = {
    fish.enable = lib.mkEnableOption "enable custom configured fish";
  };

  config = lib.mkIf config.fish.enable {
    home.packages = with pkgs; [
      eza
      tree
      croc
      dust
      bat
      zip
      unzip
      duf
      wget
      curl
      sqlite
      pre-commit
    ];

    programs = {
      fish = {
        enable = true;
        shellAbbrs = {
          nixb = "sudo nixos-rebuild switch --flake /home/jens/nixos#default";
          rf = "exec fish";
          rfc = "clear && exec fish";
          dr = "darwin-rebuild switch --flake ~/repos/nix/#macbook";
          obs =
            "pushd ~/repos/notes; git status; git add .; gstatus; git commit --message 'commit from abbr'; gstatus; git push; popd;";
          code = "code-insiders";
          xc-sim =
            "xcodebuild -scheme Nanolet -destination 'platform=iOS Simulator,name=iPhone 16' BUILD_DIR=./build; xcrun simctl install booted ./build/Debug-iphonesimulator/Nanolet.app/; xcrun simctl launch booted Unincorporated.Dev.Nanolet";
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

          set -x DIRENV_LOG_FORMAT
          set -x TERM xterm-256color

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
          {
            name = "bass";
            src = pkgs.fishPlugins.bass.src;
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
    };
  };
}
