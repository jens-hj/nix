{
  pkgs,
  config,
  lib,
  ...
}: {
  options = {
    utils.git.enable = lib.mkEnableOption "enables custom configured git";
  };

  config = lib.mkIf config.utils.git.enable {
    home.packages = with pkgs; [
      difftastic
    ];
    programs.git = {
      enable = true;
      userName = "Jens";
      userEmail = "jens.jens@live.dk";
      extraConfig = {diff.external = "difft";};
    };
  };
}
