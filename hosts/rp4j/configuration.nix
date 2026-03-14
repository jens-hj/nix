# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware.nix
  ];

  home-manager.users.pi = {
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

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Boot loader
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  # Networking
  networking.hostName = "rp4j"; # Define your hostname.
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Copenhagen";

  # User
  users.users.pi = {
    isNormalUser = true;
    extraGroups = ["wheel"]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILh7s/A2WOBY+O+Q10iwZ5L0dqfbVc+5IaaT9VUHvcl5 jens@Jenss-MacBook-Pro.local"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPPIvVodq02iIsuc1TtTS/OHg60ep76xlf3WTxU26jcc j@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKHyh2EJs5CDdPmiRIRMowuvSu8fBK/ujQ3bhzXQmY5K kevork@karch"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM69Jr7kV8zSYeoBg5Zvdd5YdHnSNrFe7ze9uzhUeWdv kevork@DESKTOP-AN2MVEF"
    ];
  };

  # System packages
  environment.systemPackages = with pkgs; [
    helix
    wget
    git
  ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  # sudo without password
  security.sudo.wheelNeedsPassword = false;

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "26.05";
}
