{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: {
  imports = [
    inputs.nix-minecraft.nixosModules.minecraft-servers
  ];

  options = {
    srv.minecraft.enable = lib.mkEnableOption "enable minecraft servers";
  };

  config = lib.mkIf config.srv.minecraft.enable {
    nixpkgs.overlays = [
      inputs.nix-minecraft.overlay
    ];

    services.minecraft-server = {
      enable = true;
      eula = true;
      dataDir = "/home/nix/srv/minecraft";

      servers = {
        test = {
          enable = true;
          package = pkgs.papermcServers.papermc-1_21_6;
          # openFirewall = true;

          whitelist = {
            Baltakopa20 = "721a58a5-f31f-4a9b-81ae-3a358fab48ed";
            KevorkDK = "0a2682bd-b70e-4012-b6c6-60253123c12f";
            jens7677 = "2a5f6930-60a6-4f6b-b5ff-76fddc783e8b";
            Avianastra = "6e86c312-b73f-4019-a354-e8108678efdc";
            zSorath = "ad7c2600-8033-4b9e-8628-7e98cfc4e1d4";
            anne899j = "7335dbaf-e7f7-4a42-85c4-e6ade5787aa0";
            DaDudeIan = "1650bfa0-24a6-4181-8fc2-aba35809bb05";
            k1000aR = "3255c286-5386-41bb-95e9-da25db41acb6";
          };

          operators = {
            KevorkDK = {
              uuid = "0a2682bd-b70e-4012-b6c6-60253123c12f";
              level = 4;
              bypassesPlayerLimit = false;
            };
            jens7677 = {
              uuid = "2a5f6930-60a6-4f6b-b5ff-76fddc783e8b";
              level = 4;
              bypassesPlayerLimit = true;
            };
            Avianastra = {
              uuid = "6e86c312-b73f-4019-a354-e8108678efdc";
              level = 4;
              bypassesPlayerLimit = true;
            };
          };

          serverProperties = {
            motd = "§9§l§oBOP §4§l§oBIP";
            white-list = true;
            enforce-whitelist = true;
            enable-rcon = true;
            "rcon.password" = "7568";
          };

          jvmOpts = "-Xmx8G -Xms8G";
        };
      };
    };
  };
}
