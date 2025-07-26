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
    srv.minecraft.importExistingFiles = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/path/to/existing/minecraft/server";
      description = "Path to existing Minecraft server files to import (as string to avoid pure evaluation issues)";
    };
  };

  config = lib.mkIf config.srv.minecraft.enable {
    nixpkgs.overlays = [
      inputs.nix-minecraft.overlay
    ];

    # Create the data directory with proper permissions
    systemd.tmpfiles.rules = [
      "d /srv/minecraft 0770 minecraft minecraft -"
      "d /srv/minecraft/commune 0770 minecraft minecraft -"
      "Z /srv/minecraft 0770 minecraft minecraft -"
      "d /srv/minecraft/backups 0770 minecraft minecraft -"
    ];

    # Add your user to the minecraft group to access server files
    users.groups.minecraft.members = ["nix"];

    # Create the server directory ahead of time
    system.activationScripts.minecraftDir = ''
      mkdir -p /srv/minecraft/commune
      chown -R minecraft:minecraft /srv/minecraft
      chmod -R 770 /srv/minecraft

      ${lib.optionalString (config.srv.minecraft.importExistingFiles != null) ''
        # Import existing server files if specified
        IMPORT_PATH="${config.srv.minecraft.importExistingFiles}"
        echo "Importing existing Minecraft server files from $IMPORT_PATH..."

        # Create backup of current files if they exist
        if [ -d /srv/minecraft/commune/world ]; then
          BACKUP_DIR="/srv/minecraft/backups/$(date +%Y%m%d_%H%M%S)"
          mkdir -p "$BACKUP_DIR"
          cp -r /srv/minecraft/commune/world "$BACKUP_DIR/"
          echo "Backed up existing world to $BACKUP_DIR"
        fi

        # Copy important directories and files from existing server
        # Exclude files that should be managed by NixOS

        # World directories
        cp -r "$IMPORT_PATH/world" /srv/minecraft/commune/ 2>/dev/null || true
        cp -r "$IMPORT_PATH/world_nether" /srv/minecraft/commune/ 2>/dev/null || true
        cp -r "$IMPORT_PATH/world_the_end" /srv/minecraft/commune/ 2>/dev/null || true
        cp -r "$IMPORT_PATH/plugins" /srv/minecraft/commune/ 2>/dev/null || true

        # Datapacks
        cp -r "$IMPORT_PATH/datapacks" /srv/minecraft/commune/ 2>/dev/null || true

        # Import server icon if it exists
        cp "$IMPORT_PATH/server-icon.png" /srv/minecraft/commune/ 2>/dev/null || true

        # Import configuration files
        cp "$IMPORT_PATH/bukkit.yml" /srv/minecraft/commune/ 2>/dev/null || true
        cp "$IMPORT_PATH/spigot.yml" /srv/minecraft/commune/ 2>/dev/null || true
        cp "$IMPORT_PATH/paper.yml" /srv/minecraft/commune/ 2>/dev/null || true
        cp "$IMPORT_PATH/commands.yml" /srv/minecraft/commune/ 2>/dev/null || true
        cp "$IMPORT_PATH/permissions.yml" /srv/minecraft/commune/ 2>/dev/null || true

        # Import JSON configuration files except whitelist.json and ops.json (managed declaratively)
        for json_file in "$IMPORT_PATH"/*.json; do
          base_name=$(basename "$json_file")
          if [[ "$base_name" != "whitelist.json" && "$base_name" != "ops.json" ]]; then
            cp "$json_file" /srv/minecraft/commune/ 2>/dev/null || true
          fi
        done

        # Fix permissions
        chown -R minecraft:minecraft /srv/minecraft/commune
        chmod -R 770 /srv/minecraft/commune

        echo "Minecraft server import completed."
      ''}
    '';

    # Open both TCP and UDP ports for Minecraft and RCON
    networking.firewall = {
      allowedTCPPorts = [25565 25575]; # Minecraft and RCON
      allowedUDPPorts = [25565];
    };

    services.minecraft-servers = {
      enable = true;
      eula = true;
      # dataDir = "/home/nix/srv/minecraft";

      servers = {
        commune = {
          enable = true;
          package = pkgs.papermcServers.papermc-1_21_6;
          openFirewall = true;

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
