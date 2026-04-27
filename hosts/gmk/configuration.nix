{
  pkgs,
  inputs,
  ...
}: {
  imports = [./hardware.nix];

  # Enable the Minecraft server
  srv.minecraft = {
    enable = false;
    # importExistingFiles = "/home/gmk/srv/minecraft/commune-bak";
  };

  home-manager.users.gmk = {
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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKHyh2EJs5CDdPmiRIRMowuvSu8fBK/ujQ3bhzXQmY5K kevork@karch"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM69Jr7kV8zSYeoBg5Zvdd5YdHnSNrFe7ze9uzhUeWdv kevork@DESKTOP-AN2MVEF"
    ];
  };

  # NAS setup
  users.groups.nas = {};

  users.users.kevork = {
    isSystemUser = true;
    group = "nas";
  };

  users.users.jens = {
    isSystemUser = true;
    group = "nas";
  };

  systemd.tmpfiles.rules = [
    "d /srv/nas/kevork 0700 kevork nas -"
    "d /srv/nas/jens 0700 jens nas -"
    "d /srv/nas/shared 0770 root nas -"
  ];

  services.samba = {
    enable = true;
    openFirewall = true;
    winbindd.enable = false;
    settings = {
      global = {
        "server string" = "NAS";
        "security" = "user";
        "server min protocol" = "SMB2";
      };
      kevork = {
        path = "/srv/nas/kevork";
        browseable = "yes";
        "read only" = "no";
        "valid users" = "kevork";
      };
      jens = {
        path = "/srv/nas/jens";
        browseable = "yes";
        "read only" = "no";
        "valid users" = "jens";
      };
      shared = {
        path = "/srv/nas/shared";
        browseable = "yes";
        "read only" = "no";
        "valid users" = "@nas";
        "force group" = "nas";
        "create mask" = "0660";
        "directory mask" = "0770";
      };
    };
  };

  # macOS discovery (mDNS/Bonjour)
  services.avahi = {
    enable = true;
    openFirewall = true;
    publish.enable = true;
    publish.userServices = true;
    extraServiceFiles = {
      smb = ''
        <?xml version="1.0" standalone='no'?>
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">%h</name>
          <service>
            <type>_smb._tcp</type>
            <port>445</port>
          </service>
        </service-group>
      '';
    };
  };

  # Windows 11 discovery (WS-Discovery)
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  nixpkgs.config.allowUnfree = true;

  environment = {systemPackages = with pkgs; [helix wget git];};

  system.stateVersion = "25.05";
}
