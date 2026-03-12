# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware.nix
  ];

  home-manager.users.j = {
    imports = [
      ./home.nix
      inputs.self.outputs.homeManagerModules.default
      inputs.catppuccin.homeModules.catppuccin
      inputs.stylix.homeModules.stylix
      inputs.vicinae.homeManagerModules.default
      inputs.noctalia.homeModules.default
      inputs.zen-browser.homeModules.beta
    ];
  };

  nixpkgs.overlays = [
    inputs.nur.overlays.default
    (final: prev: {
      modrinth-app-unwrapped = prev.modrinth-app-unwrapped.overrideAttrs (old: {
        postPatch = ''
          ${old.postPatch or ""}
          sed -i '1i #![allow(dead_code)]' packages/app-lib/src/event/mod.rs
        '';
      });

      modrinth-app = prev.modrinth-app.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [pkgs.wrapGAppsHook3];
        buildInputs = (old.buildInputs or []) ++ [pkgs.gsettings-desktop-schemas];

        preFixup = ''
          ${old.preFixup or ""}
          gappsWrapperArgs+=(
            --set GDK_BACKEND x11
            --prefix XDG_DATA_DIRS : "${pkgs.gsettings-desktop-schemas}/share:${pkgs.gtk3}/share"
          )
        '';
      });

      # Replace turbo with a functional stub that runs builds via pnpm
      turbo-unwrapped = final.writeShellScriptBin "turbo" ''
        # Stub turbo that delegates to pnpm for actual building
        echo "Using turbo stub - delegating to pnpm"

        # Parse arguments to extract the actual command and filter
        COMMAND=""
        FILTER=""
        while [[ $# -gt 0 ]]; do
          case $1 in
            run)
              shift
              COMMAND="$1"
              shift
              ;;
            --filter=*)
              FILTER="''${1#*=}"
              shift
              ;;
            --filter)
              shift
              FILTER="$1"
              shift
              ;;
            *)
              shift
              ;;
          esac
        done

        # If we have a filter, run the command in that package
        if [ -n "$FILTER" ] && [ -n "$COMMAND" ]; then
          echo "Running: pnpm --filter=$FILTER run $COMMAND"
          exec ${final.pnpm}/bin/pnpm --filter="$FILTER" run "$COMMAND"
        elif [ -n "$COMMAND" ]; then
          echo "Running: pnpm run $COMMAND"
          exec ${final.pnpm}/bin/pnpm run "$COMMAND"
        else
          echo "Turbo stub: no command to run"
          exit 0
        fi
      '';

      turbo = final.turbo-unwrapped;
    })
  ];

  services.pcscd.enable = true;
  services.udev.extraRules = ''
    # Rules for Oryx web flashing and live training
    KERNEL=="hidraw*", ATTRS{idVendor}=="16c0", MODE="0664", GROUP="plugdev"
    KERNEL=="hidraw*", ATTRS{idVendor}=="3297", MODE="0664", GROUP="plugdev"

    # Legacy rules for live training over webusb (Not needed for firmware v21+)
    # Rule for all ZSA keyboards
    SUBSYSTEM=="usb", ATTR{idVendor}=="3297", GROUP="plugdev"
    # Rule for the Moonlander
    SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1969", GROUP="plugdev"
    # Rule for the Ergodox EZ
    SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="1307", GROUP="plugdev"
    # Rule for the Planck EZ
    SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="6060", GROUP="plugdev"

    # Wally Flashing rules for the Ergodox EZ
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", MODE:="0666"
    KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE:="0666"

    # Keymapp / Wally Flashing rules for the Moonlander and Planck EZ
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE:="0666", SYMLINK+="stm32_dfu"
    # Keymapp Flashing rules for the Voyager
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", MODE:="0666", SYMLINK+="ignition_dfu"
  '';

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  virtualisation = {
    containers.enable = true;
    docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
    waydroid.enable = true;
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      input = {
        General.UserspaceHID = true;
      };
      settings = {
        General = {
          Experimental = true;
          FastConnectable = true;
          # Privacy = "off";
        };
      };
    };
    graphics = {
      enable = true;
      enable32Bit = true;

      extraPackages = with pkgs; [
        mesa
        libva
        libvdpau-va-gl
        libva-vdpau-driver
        # TBoI compat attempt
        libva
        libGL
        SDL2
        libglvnd
      ];

      extraPackages32 = with pkgs.pkgsi686Linux; [
        mesa
        libva
        libvdpau-va-gl
        libva-vdpau-driver
        # TBoI compat attempt
        libva
        libGL
        SDL2
        libglvnd
      ];
    };
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = ["hid-magicmouse" "hid-playstation"];
    kernelParams = ["acpi_backlight=vendor"];
    binfmt = {
      emulatedSystems = [
        "aarch64-linux"
        "armv7l-linux"
      ];
      registrations = {
        aarch64-linux = {
          fixBinary = true;
        };
        armv7l-linux = {
          fixBinary = true;
        };
      };
    };
  };

  networking.hostName = "j-nixos-d";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Copenhagen";

  i18n.defaultLocale = "en_DK.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "da_DK.UTF-8";
    LC_IDENTIFICATION = "da_DK.UTF-8";
    LC_MEASUREMENT = "da_DK.UTF-8";
    LC_MONETARY = "da_DK.UTF-8";
    LC_NAME = "da_DK.UTF-8";
    LC_NUMERIC = "da_DK.UTF-8";
    LC_PAPER = "da_DK.UTF-8";
    LC_TELEPHONE = "da_DK.UTF-8";
    LC_TIME = "da_DK.UTF-8";
  };

  services = {
    xserver.xkb = {
      layout = "us";
      variant = "";
    };

    # displayManager.gdm.enable = true;
    # displayManager.startx.enable = true;
    desktopManager.gnome.enable = true;

    gnome.gnome-keyring.enable = true;

    # xserver.enable = true;
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd ${pkgs.niri}/bin/niri-session";
          user = "greeter";
        };
      };
    };

    printing.enable = true;

    # Enable sound with pipewire.
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    onedrive.enable = true;

    flatpak.enable = true;
  };

  systemd.user.services.orca.enable = false;

  security = {
    rtkit.enable = true;
    pam.services.greetd.enableGnomeKeyring = true;
    pam.services.login.enableGnomeKeyring = true;
  };

  users.defaultUserShell = pkgs.fish;
  users.groups.plugdev = {};
  users.users.j = {
    isNormalUser = true;
    description = "j";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "plugdev"
      "libvirtd"
      "kvm"
      "video"
      "render"
      "i2c"
    ];
  };

  # Install firefox.
  programs = {
    obs-studio.enable = true;
    virt-manager.enable = true;
    appimage.enable = true;
    niri.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers

      gamescopeSession.enable = true;

      # And this for better compatibility:
      extraCompatPackages = with pkgs; [
        proton-ge-bin
        libXcursor
        libXi
        libXinerama
        libXScrnSaver
        libpng
        libpulseaudio
        libvorbis
        stdenv.cc.cc.lib
        libkrb5
        keyutils
      ];
    };
    # something else?
  };

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "libsoup-2.74.3"
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    helix
    wget
    pciutils
    xwayland
    xwayland-satellite
    qemu
    gsettings-desktop-schemas
    gtk3
    ffmpeg # Not strictly required, but ensures VAAPI stack is complete
    libva-utils # For testing with 'vainfo' command
    # For Windows VM
    swtpm
    OVMF
  ];

  environment.variables = {
    DISTROBOX_HOST_PATH = "/home/j/.local/bin";
    LIBVA_DRIVER_NAME = "radeonsi";
    LIBVA_DRIVERS_PATH = "/run/opengl-driver/lib/dri";
    VDPAU_DRIVER_PATH = "/run/opengl-driver/lib/vdpau";
    MOZ_DISABLE_RDD_SANDBOX = "1";
    # Enable native Wayland mode for all Chromium/Electron apps (Brave, Vesktop, etc.)
    # Without this they fall back to XWayland and lose GPU acceleration + PipeWire screen capture
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    # Hint Electron apps to use PipeWire for screen capture
    ELECTRON_ENABLE_PIPEWIRE = "1";
    # Force Vulkan to prefer the discrete AMD GPU over the Intel iGPU
    # Fixes WebGPU adapter selection and ensures Vulkan apps use the RX 9070 XT
    MESA_VK_DEVICE_SELECT = "1002:7550";
  };

  environment.pathsToLink = [
    "/share/gsettings-schemas"
  ];

  # Vicinae
  nix.settings = {
    extra-substituters = ["https://vicinae.cachix.org"];
    extra-trusted-public-keys = ["vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="];
  };

  system.stateVersion = "25.05";
}
