{
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware.nix
  ];

  home-manager.users.pi = {
    imports = [
      ./home.nix
      inputs.self.outputs.homeManagerModules.default
      inputs.self.outputs.homeManagerModules.linux
      inputs.noctalia.homeModules.default
      # Stub catppuccin / stylix on home-manager too — same nixpkgs-pin
      # mismatch as the system side. theme/wallpaper are disabled on this
      # host, so no real assignments hit these stubs.
      ({lib, ...}: {
        options.catppuccin = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
          flavor = lib.mkOption {
            type = lib.types.str;
            default = "mocha";
          };
        };
        options.stylix = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
          autoEnable = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
          image = lib.mkOption {
            type = lib.types.anything;
            default = null;
          };
          base16Scheme = lib.mkOption {
            type = lib.types.anything;
            default = null;
          };
          polarity = lib.mkOption {
            type = lib.types.str;
            default = "dark";
          };
          fonts = lib.mkOption {
            type = lib.types.anything;
            default = {};
          };
          targets = lib.mkOption {
            type = lib.types.anything;
            default = {};
          };
        };
      })
    ];
  };

  # Headless worker — no theming
  visuals.theme.enable = lib.mkForce false;
  desktop.noctalia.enable = lib.mkForce false;

  # k3s
  srv.k3s.agent.enable = lib.mkForce true;

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    substituters = [
      "https://cache.nixos.org"
      "https://nixos-raspberrypi.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  # Networking
  networking.hostName = "rp5j";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Copenhagen";

  # User
  users.users.pi = {
    isNormalUser = true;
    extraGroups = ["wheel"];
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

  # OpenSSH
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  # sudo without password
  security.sudo.wheelNeedsPassword = false;

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "26.05";
}
