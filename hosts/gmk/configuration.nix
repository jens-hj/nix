{
  pkgs,
  inputs,
  ...
}: {
  imports = [./hardware.nix];

  # Enable the Minecraft server
  srv.minecraft = {
    enable = false;
    # importExistingFiles = "/home/nix/srv/minecraft/commune-bak";
  };

  home-manager.users.nix = {
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

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  networking.hostName = "gmk";
  networking.networkmanager.enable = true;

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
  # services.xserver.xkb = {
  #   layout = "us";
  #   variant = "";
  # };
  # services.xserver.enable = true;
  # services.displayManager.gdm = {
  #   enable = true;
  #   autoSuspend = false;
  # };
  # services.desktopManager.gnome = {
  #   enable = true;
  #   extraGSettingsOverrides = ''
  #     [org.gnome.settings-daemon.plugins.power]
  #     sleep-inactive-ac-type='nothing'
  #     sleep-inactive-battery-type='nothing'
  #   '';
  # };

  # Modern audio setup with PipeWire
  # PipeWire provides complete audio stack with ALSA and PulseAudio compatibility
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # Use the WirePlumber session manager
    wireplumber.enable = true;
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  users.defaultUserShell = pkgs.fish;
  users.users.nix = {
    isNormalUser = true;
    description = "nix";
    extraGroups = ["networkmanager" "wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILh7s/A2WOBY+O+Q10iwZ5L0dqfbVc+5IaaT9VUHvcl5 jens@Jenss-MacBook-Pro.local"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPPIvVodq02iIsuc1TtTS/OHg60ep76xlf3WTxU26jcc j@nixos"
    ];
  };

  # services.displayManager.autoLogin.enable = true;
  # services.displayManager.autoLogin.user = "nix";

  # systemd.services."getty@tty1".enable = false;
  # systemd.services."autovt@tty1".enable = false;

  nixpkgs.config.allowUnfree = true;

  environment = {systemPackages = with pkgs; [helix wget git];};

  system.stateVersion = "25.05";
}
