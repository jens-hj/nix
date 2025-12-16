{
  pkgs,
  config,
  lib,
  ...
}:
{
  options = {
    utils.git = {
      enable = lib.mkEnableOption "enables custom configured git";
      profile = lib.mkOption {
        type = lib.types.enum [
          "personal"
          "work"
        ];
        default = "personal";
        description = "Git profile to use (personal or work)";
      };
    };
  };

  config = lib.mkIf config.utils.git.enable {
    home.packages = with pkgs; [
      difftastic
      gh
    ];

    programs.git = lib.mkMerge [
      # Base git configuration
      {
        enable = true;
        settings.diff.external = "difft";
      }

      # Personal git configuration
      (lib.mkIf (config.utils.git.profile == "personal") {
        settings.user.name = "Jens";
        settings.user.email = "jens.jens@live.dk";
      })

      # Work git configuration
      (lib.mkIf (config.utils.git.profile == "work") {
        settings.user.name = "Jens Jensen";
        settings.user.email = "jjs@systematic.com";
        settings = {
          core.longpaths = true;
          core.autocrlf = false;
          merge.renamelimit = 50000;
          http.sslbackend = "schannel";
        };
      })
    ];
  };
}
