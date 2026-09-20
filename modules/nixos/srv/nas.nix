{
  config,
  lib,
  ...
}: {
  options = {
    srv.nas.enable = lib.mkEnableOption "enables samba nas configuration";
  };

  config = lib.mkIf config.srv.nas.enable {
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
  };
}
