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
  networking.hostName = "gmk1";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Copenhagen";

  security.rtkit.enable = true;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

  users.defaultUserShell = pkgs.fish;
  users.users.gmk = {
    isNormalUser = true;
    extraGroups = ["networkmanager" "wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILh7s/A2WOBY+O+Q10iwZ5L0dqfbVc+5IaaT9VUHvcl5 jens@Jenss-MacBook-Pro.local"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPPIvVodq02iIsuc1TtTS/OHg60ep76xlf3WTxU26jcc j@nixos"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  environment = {systemPackages = with pkgs; [helix wget git];};

  system.stateVersion = "25.05";
}
