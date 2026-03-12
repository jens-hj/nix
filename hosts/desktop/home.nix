{
  pkgs,
  lib,
  inputs,
  ...
}: {
  home.username = "j";
  home.homeDirectory = "/home/j";

  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    wl-clipboard
    mcrcon
    k9s
    just
    pgweb
    telegram-desktop
    signal-desktop
    session-desktop
    yubioath-flutter
    bitwarden-desktop
    equibop
    notion-app-enhanced
    heroic
    # appimage-run
    # inputs.awww.packages.${pkgs.system}.awww
    bluetuith
    p7zip
    swaybg
    gtk3
    webkitgtk_4_1
    libusb1
    keymapp
    wiremix
    winetricks
    distrobox
    distrobox-tui
    obsidian
    libsoup_2_4
    speedtest
    brave
    inputs.t3code.packages.${system}.t3-code
    # zen-browser
    radeontop
    cacert
    blender
    qutebrowser
    caprine
    libsecret
    pulseaudio
    python3
    parsec-bin
    lmstudio
    # Virtualisation for Windows VM
    virt-manager
    virt-viewer
    spice-gtk
    virtio-win
  ];

  # Enable the custom base configuration from ./../../modules/default.nix
  base.enable = true;
  shell.fish.zellij.autoStart = lib.mkForce false;
  terminal.ghostty.enable = lib.mkForce true;
  typesetters.typst.enable = lib.mkForce true;
  utils.cli.profile = lib.mkForce "extended";
  editor.zed.enable = lib.mkForce true;
  editor.vscode.enable = lib.mkForce true;

  games.enable = true;

  desktop.enable = true;

  programs = {
    firefox = {
      enable = true;
      profiles.default.extensions.force = true;
      profiles.default.extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        bitwarden
        consent-o-matic
        darkreader
        enhanced-h264ify
        sponsorblock
        twitch-auto-points
        # 7TV and IVE not in NUR - install manually
      ];
      profiles.default.settings = {
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.force-enabled" = true;
        "media.av1.enabled" = true;
        # Force DMABUF - gfxInfo blocklists gfx1201 (RDNA4) as "broken driver"
        # because it's too new to be in the allowlist, but it works fine
        "widget.dmabuf.force-enabled" = true;
        "widget.dmabuf.surface-export.force-enabled" = true;
        # Use PipeWire for WebRTC screen/camera capture on Wayland
        "media.webrtc.camera.allow-pipewire" = true;
        "media.webrtc.capture.allow-pipewire" = true;
      };
    };
    zen-browser = {
      enable = true;
      profiles.default.extensions.force = true;
      profiles.default.extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        bitwarden
        consent-o-matic
        darkreader
        enhanced-h264ify
        sponsorblock
        twitch-auto-points
        # 7TV and IVE not in NUR - install manually
      ];
      profiles.default.settings = {
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.force-enabled" = true;
        "media.av1.enabled" = true;
        # Force DMABUF - gfxInfo blocklists gfx1201 (RDNA4) as "broken driver"
        # because it's too new to be in the allowlist, but it works fine
        "widget.dmabuf.force-enabled" = true;
        "widget.dmabuf.surface-export.force-enabled" = true;
        # gfxInfo in Zen records a runtime VIDEO_DECODING_TEST_FAILED for gfx1201
        # and force-disables HW decode even with force-enabled pref.
        # Allow VAAPI texture storage to prevent the texture allocation sub-test from failing.
        "gfx.vaapi.allow-texture-storage" = true;
        # Zen disables WebGPU by default; explicitly enable it
        "dom.webgpu.enabled" = true;
        # Zen's gfxInfo database doesn't include gfx1201 in the encode allowlist
        # yet (Firefox's does). Force-enable to bypass the MISSING blocklist.
        "media.hardware-video-encoding.force-enabled" = true;
        # Use PipeWire for WebRTC screen/camera capture on Wayland
        "media.webrtc.camera.allow-pipewire" = true;
        "media.webrtc.capture.allow-pipewire" = true;
        # Skip first-run screens
        "zen.welcome-screen.seen" = true;
        "app.normandy.first_run" = false;
        # Tabs sidebar on the right
        "zen.tabs.vertical.right-side" = true;
        # Disable built-in password manager — use Bitwarden extension instead
        "signon.rememberSignons" = false;
        "signon.autofillForms" = false;
        # Default zoom 130%
        "layout.css.devPixelsPerPx" = "1.3";
        # Ctrl+Tab cycles by most recently used (like Alt+Tab)
        "browser.ctrlTab.sortByRecentlyUsed" = true;
      };

      profiles.default.mods = [
        "fd24f832-a2e6-4ce9-8b19-7aa888eb7f8e" # Quietify
      ];

      profiles.default.spacesForce = true;
      profiles.default.spaces = {
        main = {
          id = "077b7c27-6a5e-4e1e-801a-d964d958816c";
          name = "Main";
          position = 1;
          icon = "chrome://browser/skin/zen-icons/selectable/code.svg";
          theme.type = "gradient";
          theme.colors = [
            {
              red = 100;
              green = 150;
              blue = 230;
              primary = true;
              algorithm = "floating";
            }
          ];
          theme.opacity = 0.5;
        };
        work = {
          id = "29c6ef7d-f896-44e5-bb2d-5c3411fb8dbe";
          name = "Work";
          position = 2;
          icon = "chrome://browser/skin/zen-icons/selectable/briefcase.svg";
          theme.type = "gradient";
          theme.colors = [
            {
              red = 230;
              green = 100;
              blue = 80;
              primary = true;
              algorithm = "floating";
            }
          ];
          theme.opacity = 0.5;
        };
      };

      # pinsForce = false so manually-created folder structure survives rebuilds
      # (folder grouping is not supported by the NixOS module yet — isGroup/folderParentId
      # options exist in the schema but are not mapped to any JSON fields)
      profiles.default.pinsForce = false;
      profiles.default.pins = {
        # Work space pins
        teams = {
          id = "8962d57c-3f55-4082-bd90-a8697bb7043c";
          title = "Teams";
          url = "https://teams.cloud.microsoft/";
          position = 1;
          workspace = "29c6ef7d-f896-44e5-bb2d-5c3411fb8dbe";
        };
        avd = {
          id = "446f8f25-3b51-4f00-9382-875ca03ee59b";
          title = "AVD";
          url = "https://windows.cloud.microsoft/webclient/avd/78203a41-73f3-48e6-923f-af879b1e165f/012f2293-8605-4e01-7b16-08dcf66f37d9#loginHint=jjs%40systematic.com";
          position = 2;
          workspace = "29c6ef7d-f896-44e5-bb2d-5c3411fb8dbe";
        };
        # Main space — essential pins
        github = {
          id = "d05a72d4-7fb4-4f56-8753-c832777cee0b";
          title = "GitHub";
          url = "https://github.com/";
          isEssential = true;
          position = 1;
          workspace = "077b7c27-6a5e-4e1e-801a-d964d958816c";
        };
        twitch = {
          id = "25668f06-3f7b-40f3-8fc7-c29c28e094ab";
          title = "Twitch";
          url = "https://www.twitch.tv/directory/following";
          isEssential = true;
          position = 2;
          workspace = "077b7c27-6a5e-4e1e-801a-d964d958816c";
        };
        disney-plus = {
          id = "b7780f15-ff6c-44c3-a3b6-1bd1d7f2719e";
          title = "Disney+";
          url = "https://www.disneyplus.com/en-gb/home";
          isEssential = true;
          position = 3;
          workspace = "077b7c27-6a5e-4e1e-801a-d964d958816c";
        };
        netflix = {
          id = "e88a37d1-391d-47a0-8548-e2570e08a3da";
          title = "Netflix";
          url = "https://www.netflix.com/browse";
          isEssential = true;
          position = 4;
          workspace = "077b7c27-6a5e-4e1e-801a-d964d958816c";
        };
        hbo-max = {
          id = "43b96582-ba67-40a9-87f5-c853757c3ae6";
          title = "Max";
          url = "https://play.hbomax.com/";
          isEssential = true;
          position = 5;
          workspace = "077b7c27-6a5e-4e1e-801a-d964d958816c";
        };
        google-calendar = {
          id = "8ad9b2a0-2714-4856-8c56-4b5df97a77bc";
          title = "Google Calendar";
          url = "https://calendar.google.com/calendar/";
          isEssential = true;
          position = 6;
          workspace = "077b7c27-6a5e-4e1e-801a-d964d958816c";
        };
        trakt = {
          id = "d244db8f-ca9f-434e-bf95-4d278c2a25b5";
          title = "Trakt";
          url = "https://app.trakt.tv/";
          isEssential = true;
          position = 7;
          workspace = "077b7c27-6a5e-4e1e-801a-d964d958816c";
        };
        youtube = {
          id = "8eb1c83b-3c43-48a1-bc20-c2bfddd51254";
          title = "YouTube";
          url = "https://www.youtube.com/";
          isEssential = true;
          position = 8;
          workspace = "077b7c27-6a5e-4e1e-801a-d964d958816c";
        };
        youtube-music = {
          id = "f01afdba-0389-4b4d-95a7-d8b12c03670d";
          title = "YouTube Music";
          url = "https://music.youtube.com/";
          isEssential = true;
          position = 9;
          workspace = "077b7c27-6a5e-4e1e-801a-d964d958816c";
        };
        prime-video = {
          id = "21074353-210b-4f79-9303-fb50b1fe7b3d";
          title = "Prime Video";
          url = "https://www.primevideo.com/";
          isEssential = true;
          position = 10;
          workspace = "077b7c27-6a5e-4e1e-801a-d964d958816c";
        };
        instagram-dm = {
          id = "dbce7384-c541-4b01-a55d-ca09189a597c";
          title = "Instagram";
          url = "https://www.instagram.com/direct/";
          isEssential = true;
          position = 11;
          workspace = "077b7c27-6a5e-4e1e-801a-d964d958816c";
        };
        discord = {
          id = "6dd29a96-3ead-405c-9fd0-033f5eac34a6";
          title = "Discord";
          url = "https://discord.com/channels/@me";
          isEssential = true;
          position = 12;
          workspace = "077b7c27-6a5e-4e1e-801a-d964d958816c";
        };
      };
    };
    ghostty.settings = {
      font-size = 18;
    };
    fish.shellAliases = {
      zed = "zeditor";
    };
    claude-code = {
      enable = true;
    };
    uv.enable = true;
    vesktop = {
      enable = true;
      package = pkgs.vesktop.overrideAttrs (old: {
        postFixup =
          old.postFixup
          + ''
            wrapProgram $out/bin/vesktop \
              --add-flags "--enable-features=WebRTCPipeWireCapturer,VaapiVideoEncoder,VaapiVideoDecodeLinuxGL,VaapiIgnoreDriverChecks,PlatformHEVCEncoderSupport"
          '';
      });
    };
  };

  services = {
    vicinae = {
      enable = true;
      systemd.enable = true;
      settings = {
        font.size = 12;
      };
    };
    flameshot = {
      enable = true;
      settings = {
        General = {
          useGrimAdapter = true;
          disabledTrayIcon = true;
          showStartupLaunchMessage = false;
        };
      };
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    config.common.default = "gnome";
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/wm/keybindings" = {
        # Set Alt+Tab to switch windows instead of applications
        switch-applications = [];
        switch-windows = ["<Alt>Tab"];

        switch-applications-backward = [];
        switch-windows-backward = ["<Shift><Alt>Tab"];
      };

      # Optional: allow switching windows across workspaces
      "org/gnome/shell/window-switcher" = {
        current-workspace-only = false;
      };

      "org/gnome/desktop/a11y/applications" = {
        screen-reader-enabled = false;
      };

      "org/gnome/desktop/interface" = {
        toolkit-accessibility = false;
      };
    };
  };

  home.sessionVariables = {
    SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    SSL_CERT_DIR = "${pkgs.cacert}/etc/ssl/certs";
    DISTROBOX_HOST_PATH = "$HOME/.local/bin";
    PATH = "$PATH:~/.cargo/bin";
    MCRCON_HOST = "localhost";
    MCRCON_PASS = "7568";
    COLORTERM = "truecolor";
    fish_term24bit = "1";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    TERM = "xterm-256color";
    XDG_DATA_DIRS = "$XDG_DATA_DIRS:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share:$HOME/.nix-profile/share";
    LIBVA_DRIVER_NAME = "radeonsi";
    VDPAU_DRIVER = "radeonsi";
  };
}
