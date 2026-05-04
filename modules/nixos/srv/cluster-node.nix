{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    srv.clusterNode.enable = lib.mkEnableOption "configures this machine as a cluster node";
  };

  config = lib.mkIf config.srv.clusterNode.enable {
    nix.settings.experimental-features = ["nix-command" "flakes"];

    networking.networkmanager.enable = true;

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

    environment.systemPackages = with pkgs; [
      helix
      wget
      git
    ];

    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };

    security.sudo.wheelNeedsPassword = false;

    nixpkgs.config.allowUnfree = true;

    srv.k3s.agent.enable = lib.mkDefault true;
  };
}
