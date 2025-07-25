# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:
let tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
in {
  imports = [ # Include the results of the hardware scan.
    ./hardware/default.nix
    inputs.home-manager.nixosModules.default
  ];

  home-manager.users.jens = {
    # extraSpecialArgs = { inherit inputs; };
    imports = [
      ./home.nix
      inputs.catppuccin.homeManagerModules.catppuccin
      inputs.stylix.homeManagerModules.stylix
      inputs.niri.homeModules.niri
    ];
  };

  security.rtkit.enable = true;

  # stylix.enable = true;

  services = {
    # sound
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };
    # Configure keymap in X11
    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
      displayManager.startx.enable = true;
    };
    # login manager
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${tuigreet} --time --remember --cmd niri-session";
          user = "greeter";
        };
      };
    };
  };

  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    # Without this errors will spam on screen
    StandardError = "journal";
    # Without these boot logs will spam on screen
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    defaultUserShell = pkgs.fish;
    users.jens = {
      isNormalUser = true;
      description = "Jens";
      extraGroups = [ "networkmanager" "wheel" "audio" "openrazer" ];
      packages = with pkgs; [ ];
    };
  };

  # home manager
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = { "jens" = import ./home.nix; };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs = {
    fish.enable = true;
    # hyprland.enable = true;
    firefox.enable = true;
    # niri.enable = true;
  };

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    pulsemixer
    pulseaudio
    wireplumber
    helix
    wget
    bottom
    kitty
    pciutils
    # niri
    wlroots
  ];

  xdg.portal = {
    enable = true;
    wlr = {
      enable = true;
      settings = { screencast = { screencopy_version = 1; }; };
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
    config.common.default = "*";
  };

  environment.sessionVariables = {
    BEMENU_SCALE = "1.5";
    NIXOS_OZONE_WL = "1";
    RELEASE_CONTAINER_ENGINE = "docker";
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [ "https://niri.cachix.org" ];
    trusted-public-keys =
      [ "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964=" ];
    trusted-substituters = [ "https://niri.cachix.org" ];
  };

  # sound.enable = true;
  hardware = {
    openrazer.enable = true;
    graphics.enable = true;
    nvidia = {
      modesetting.enable = true;
      # enable this if crashes happen caused by nvidia gpu
      powerManagement.enable = true;
      # turns gpu off when not in use (experimental)
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
    bluetooth.enable = true;
  };

  # Bootloader.
  boot = {
    # blacklistedKernelModules = [ "nouveau" ];
    loader = {
      # systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        devices = [ "nodev" ];
        efiSupport = true;
        useOSProber = true;
      };
    };
  };

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # Select internationalisation properties.
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
