{
  pkgs,
  config,
  lib,
  ...
}:
{
  options = {
    shell.fish.enable = lib.mkEnableOption "enable custom configured fish";
    shell.brew.enable = lib.mkEnableOption "enable homebrew in fish";
    shell.fish.zellij.autoStart = lib.mkEnableOption "enable zellij autostart";
  };

  config = lib.mkIf config.shell.fish.enable {
    home.packages = with pkgs; [
      grc
      eza
      tree
      sqlite
      pre-commit
    ];

    programs = {
      fish = {
        enable = true;
        shellAbbrs = {
          wgradle = "pwsh.exe -c ./gradlew";
          wgradleb = "pwsh.exe -c ./gradlew build";
          wgradlebd = "pwsh.exe -c ./gradlew build deploy";
          wgradled = "pwsh.exe -c ./gradlew deploy";
          wind = {
            position = "anywhere";
            setCursor = true;
            expansion = "/mnt/c/Users/jjs/%";
          };
          PS = "pwsh.exe";
          rf = "exec fish";
          rfc = "clear && exec fish";
          obs = "pushd ~/repos/notes; git status; git add .; gstatus; git commit --message 'commit from abbr'; gstatus; git push; popd;";
          xc-sim = "xcodebuild -scheme Nanolet -destination 'platform=iOS Simulator,name=iPhone 16' BUILD_DIR=./build; xcrun simctl install booted ./build/Debug-iphonesimulator/Nanolet.app/; xcrun simctl launch booted Unincorporated.Dev.Nanolet";
        };
        shellAliases = {
          space = "duf --hide-fs squashfs";
          ls = "eza --icons --group-directories-first --classify --grid";
          ll = "eza --icons --group-directories-first --classify --long --header --git";
          ns = "nix-search-tv print | fzf --preview 'nix-search-tv preview {}' --scheme history";
        };
        interactiveShellInit = ''
          set fish_greeting # Disable greeting

          ${lib.optionalString config.shell.brew.enable ''
            eval "$(/opt/homebrew/bin/brew shellenv)"
          ''}

          set -x DIRENV_LOG_FORMAT
          set -x TERM xterm-256color

          bind \t 'super-tab'

          ${lib.optionalString config.shell.fish.zellij.autoStart ''
            # Start or attach to Zellij session
            zellij-auto
          ''}
        '';
        shellInit = ''
          set --universal git_fish_git_status_command gstatus

          # Use gh's existing auth for GitHub API
          if command -v gh &> /dev/null
            set -gx GITHUB_TOKEN (gh auth token 2>/dev/null)
          end
        '';
        functions = {
          nixr = {
            description = "Rebuild NixOS configuration with flake";
            body = ''
              if test (count $argv) -eq 0
                  echo "Error: Configuration name is required"
                  echo "Usage: nixr <config-name>"
                  echo "Available configurations: default (d), gmk (g), macbook (m)"
                  return 1
              end

              set -l input $argv[1]
              set -l config

              # Map short names to full configuration names
              switch $input
                  case d
                      set config "default"
                  case g
                      set config "gmk"
                  case m
                      set config "macbook"
                  case '*'
                      set config $input
              end

              if test "$config" = "macbook"
                  echo "Rebuilding Darwin configuration: $config"
                  sudo darwin-rebuild switch --flake ~/repos/nix/#$config
              else
                  echo "Rebuilding NixOS configuration: $config"
                  sudo nixos-rebuild switch --flake ~/repos/nix/#$config
              end
            '';
          };
          super-tab = {
            description = "Enhanced tab completion that opens repos when empty line";
            body = ''
              commandline --paging-mode && down-or-search && return

              set -l buf (commandline)
              if string match -q -r '^\s*$' -- $buf
                  repos cd
              else
                  commandline -f complete
                  commandline -f pager-toggle-search
              end
              commandline -f repaint
            '';
          };
          zellij-auto = {
            description = "Smart Zellij session management with terminal-specific sessions";
            body = ''
              # Skip if already in a Zellij session
              if set -q ZELLIJ
                  return
              end

              # Determine terminal type and session name
              set -l term_type "default"
              set -l is_visor false

              # Better terminal detection
              set -l term_cmd (ps -p $fish_pid -o ppid= | xargs ps -p -o comm= 2>/dev/null)

              # Get window title and TERM_PROGRAM for additional detection methods
              set -l term_program (echo $TERM_PROGRAM 2>/dev/null)
              set -l window_title (echo $KITTY_WINDOW_TITLE $WINDOW_TITLE $WEZTERM_PANE_TITLE 2>/dev/null)

              # Check for iTerm (case-insensitive)
              if set -q ITERM_SESSION_ID; or string match -qi "*iterm*" "$term_cmd"; or string match -qi "*iterm*" "$term_program"; or string match -qi "*iterm*" "$window_title"
                  set term_type "iterm"

                  # Check window dimensions for potential visor detection
                  # Visor is typically a short window at the top of the screen
                  # Adjust these values based on your visor's typical dimensions
                  set -l rows (tput lines)
                  set -l cols (tput cols)

                  if test "$rows" -lt 20
                      set is_visor true
                      set term_type "iterm-visor"
                  end

                  # Alternative: Detect by profile name if you set a specific profile for visor (case-insensitive)
                  if set -q ITERM_PROFILE; and string match -qi "*visor*" "$ITERM_PROFILE"
                      set is_visor true
                      set term_type "iterm-visor"
                  end
              end

              # Check for Ghostty (case-insensitive)
              # Multiple detection methods for better reliability
              if string match -qi "*ghostty*" "$term_cmd"; or string match -qi "*ghostty*" "$term_program"; or string match -qi "*ghostty*" "$window_title"
                  set term_type "ghostty"
              end

              # Check for Alacritty (case-insensitive)
              if string match -qi "*alacritty*" "$term_cmd"; or string match -qi "*alacritty*" "$term_program"; or string match -qi "*alacritty*" "$window_title"
                  set term_type "alacritty"
              end

              # Check for Kitty (case-insensitive)
              if string match -qi "*kitty*" "$term_cmd"; or set -q KITTY_WINDOW_ID; or string match -qi "*kitty*" "$term_program"; or string match -qi "*kitty*" "$window_title"
                  set term_type "kitty"
              end

              # Debug output to verify detection
              echo "Terminal detection: $term_type"
              if test "$is_visor" = "true"
                  echo "Detected as visor mode"
              end
              echo "Terminal command: $term_cmd"
              echo "TERM_PROGRAM: $term_program"
              echo "Window title: $window_title"
              echo "Window size: "(tput lines)" rows x "(tput cols)" columns"

              # Construct session name based on terminal type
              set -l session_name "$term_type-session"

              # List existing sessions
              set -l sessions (zellij ls 2>/dev/null)
              set -l session_exists (echo $sessions | grep -q "$session_name"; and echo "yes" || echo "no")

              # Debug: Show available sessions
              echo "Available Zellij sessions:"
              printf "%s\n" $sessions
              echo "Session '$session_name' exists: $session_exists"

              # Handle session creation or attachment
              if set -q ZELLIJ_CREATE_FORCED
                  # Force new session with unique name
                  set -l timestamp (date +%s)
                  zellij --session "$term_type-$timestamp"
              else if test "$session_exists" = "yes"
                  # Attach to existing session for this terminal type
                  echo "Attaching to existing $term_type session..."
                  echo "Attaching to session: $session_name"
                  zellij attach --create "$session_name"
              else
                  # Create new session for this terminal type
                  echo "Creating new $term_type session..."
                  echo "Creating new session: $session_name"
                  zellij --session "$session_name"
              end
            '';
          };
        };
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
          # {
          #   name = "rust";
          #   src = pkgs.fetchFromGitHub {
          #     owner = "kpbaks";
          #     repo = "rust.fish";
          #     rev = "16261ed8c2c987c32d6a7d2135554862f2279843";
          #     sha256 = "sha256-0vOTfAc2uiPQwEwp4hsVhxETZn+wrEmtojzamuLoCX4=";
          #   };
          # }
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
