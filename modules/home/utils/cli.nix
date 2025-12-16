{
  pkgs,
  config,
  lib,
  ...
}:
{
  options = {
    utils.cli = {
      enable = lib.mkEnableOption "enable baseline cli utils packages";
      profile = lib.mkOption {
        type = lib.types.enum [
          "essentials"
          "extended"
        ];
        default = "essentials";
        description = "profile to determine which cli utilities to install";
      };
    };
  };

  config = lib.mkIf config.utils.cli.enable {
    home.packages =
      with pkgs;
      let
        essentialPackages = [
          croc
          dust
          bat
          zip
          unzip
          duf
          wget
          curl
          file
          fd
        ];
        extendedPackages = [
          tokei
          ripgrep
          ripgrep-all
          bottom
          jq
          lolcat
          grex
          cbonsai
          asciinema
          ttyd
        ];
      in
      essentialPackages ++ lib.optionals (config.utils.cli.profile == "extended") extendedPackages;

    programs = {
      direnv.enable = true;
      fzf.enable = true;
      ssh = {
        enable = true;
        enableDefaultConfig = false;
        matchBlocks."*" = {
          forwardAgent = true;
          compression = true;
          serverAliveInterval = 60;
          controlMaster = "auto";
          controlPersist = "10m";
          controlPath = "~/.ssh/master-%r@%n:%p";
        };
      };
    };
  };
}
