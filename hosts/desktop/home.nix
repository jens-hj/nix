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
    (pkgs.writeShellScriptBin "chat-pwa" ''
      for f in ~/.local/share/applications/FFPWA-*.desktop; do
        if grep -q "Chat" "$f"; then
          id=$(grep -oP 'launch \K[A-Z0-9]+' "$f")
          exec firefoxpwa site launch "$id"
        fi
      done
      echo "Chat PWA not installed" >&2
      exit 1
    '')
    wl-clipboard
    jdk25 # Minecraft 26.3 server
    mcrcon
    k9s
    just
    nono
    pgweb
    telegram-desktop
    signal-desktop
    # session-desktop # broken: pnpm lockfile integrity mismatch upstream, re-add once fixed
    yubioath-flutter
    bitwarden-desktop
    equibop
    notion-app-enhanced
    heroic
    onedriver
    code-cursor
    bubblewrap
    # openscad
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
    libsoup_3
    speedtest
    brave
    r2modman
    firefoxpwa
    # cross compile container
    qemu-user
    # zen-browser
    radeontop
    cacert
    blender
    qutebrowser
    caprine
    libsecret
    pulseaudio
    python3
    nodejs # required by caveman Claude Code plugin hooks
    parsec-bin
    lmstudio
    # Virtualisation for Windows VM
    virt-manager
    virt-viewer
    spice-gtk
    virtio-win
    # gnome utilities (no longer auto-installed since dropping desktopManager.gnome)
    nautilus
  ];

  # Enable the custom base configuration from ./../../modules/default.nix
  base.enable = true;
  shell.fish.zellij.autoStart = lib.mkForce false;
  terminal.ghostty.enable = lib.mkForce true;
  terminal.termy.enable = lib.mkForce true;
  typesetters.typst.enable = lib.mkForce true;
  utils.cli.profile = lib.mkForce "extended";
  editor.zed.enable = lib.mkForce true;
  editor.vscode.enable = lib.mkForce true;

  games.enable = true;
  # games.minecraft.enable = lib.mkForce false;

  desktop.enable = true;
  desktop.tuicommander.enable = true;

  programs = {
    vicinae = {
      enable = true;
      systemd.enable = true;
      settings = {
        font.size = 12;
      };
    };
    thunderbird = {
      enable = true;
    };
    firefox = {
      enable = true;
      configPath = ".mozilla/firefox";
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
      nativeMessagingHosts = [pkgs.firefoxpwa];
      profiles.default.extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        bitwarden
        consent-o-matic
        darkreader
        enhanced-h264ify
        sponsorblock
        twitch-auto-points
        pwas-for-firefox
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
        "media.webrtc.camera.allow-pipewire" = false;
        "media.webrtc.capture.allow-pipewire" = true;
      };
    };
    ghostty.settings = {
      font-size = 18;
    };
    fish.shellAliases = {
      zed = "zeditor";
    };
    # claude-code = {
    #   enable = true;
    # };
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

  # home.activation.firefoxpwaUserChrome = lib.hm.dag.entryAfter ["writeBoundary"] ''
  #       for profile_dir in "$HOME/.local/share/firefoxpwa/profiles"/*/; do
  #         [ -d "$profile_dir" ] || continue
  #         mkdir -p "$profile_dir/chrome"
  #         cat > "$profile_dir/chrome/userChrome.css" << 'EOF'
  #   #navigator-toolbox {
  #     display: none !important;
  #   }
  #   EOF
  #         user_js="$profile_dir/user.js"
  #         if ! grep -q "legacyUserProfileCustomizations" "$user_js" 2>/dev/null; then
  #           echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >> "$user_js"
  #         fi
  #       done
  # '';

  # onedriver: FUSE filesystem that shows the full OneDrive tree and downloads
  # files lazily on first access (no full mirror). Auth token + content cache
  # live under ~/.cache/onedriver. First run needs an interactive login once:
  #   onedriver -a ~/OneDrive   (opens an OAuth window, stores the token)
  # then `systemctl --user start onedriver` (autostarts on login thereafter).
  systemd.user.services.onedriver = {
    Unit = {
      Description = "onedriver OneDrive lazy mount";
      After = ["network-online.target"];
      Wants = ["network-online.target"];
      StartLimitIntervalSec = 60;
      StartLimitBurst = 3;
    };
    Service = {
      # This onedriver build has no sd_notify support, so Type=notify would hang
      # until the start-job timeout. It runs in the foreground, so Type=simple is
      # correct. onedriver unmounts itself on SIGTERM; the ExecStopPost is just a
      # best-effort backstop (leading "-" so a failed/no-op unmount is ignored).
      Type = "simple";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/OneDrive";
      ExecStart = "${pkgs.onedriver}/bin/onedriver %h/OneDrive";
      ExecStopPost = "-${pkgs.fuse3}/bin/fusermount3 -uz %h/OneDrive";
      Restart = "on-abnormal";
      RestartSec = 3;
    };
    Install.WantedBy = ["default.target"];
  };

  services = {
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
    NIXOS_DEFAULT_CONFIG = "desktop";
    # OPENAI_BASE_URL = "http://127.0.0.1:1234/v1";
    # OPENAI_API_KEY = "dummy";
  };
}
