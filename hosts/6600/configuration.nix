{
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [./hardware.nix];

  home-manager.users.j = {
    imports = [
      ./home.nix
      inputs.self.outputs.homeManagerModules.default
      inputs.self.outputs.homeManagerModules.linux
      inputs.catppuccin.homeModules.catppuccin
      inputs.stylix.homeModules.stylix
      inputs.vicinae.homeManagerModules.default
      inputs.noctalia.homeModules.default
      inputs.zen-browser.homeModules.beta
    ];
  };

  # Headless server, no desktop shell services
  desktop.noctalia.enable = lib.mkForce false;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  networking.hostName = "6600";
  networking.networkmanager.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Reachable as 6600.local
  services.avahi = {
    enable = true;
    openFirewall = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };

  users.users.j = {
    isNormalUser = true;
    extraGroups = ["networkmanager" "wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILh7s/A2WOBY+O+Q10iwZ5L0dqfbVc+5IaaT9VUHvcl5 jens@Jenss-MacBook-Pro.local"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPPIvVodq02iIsuc1TtTS/OHg60ep76xlf3WTxU26jcc j@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKHyh2EJs5CDdPmiRIRMowuvSu8fBK/ujQ3bhzXQmY5K kevork@karch"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM69Jr7kV8zSYeoBg5Zvdd5YdHnSNrFe7ze9uzhUeWdv kevork@DESKTOP-AN2MVEF"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [helix wget git];

  system.stateVersion = "26.05";
}
