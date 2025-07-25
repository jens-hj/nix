{ pkgs, config, lib, ... }:
{
  options = {
    git.enable = lib.mkEnableOption "enables custom configured git";
  };

  config = lib.mkIf config.git.enable {
    home.packages = with pkgs; [
        difftastic
    ];
    programs.git = {
        enable = true;
        userName = "Jens";
        userEmail = "jens.jens@live.dk";
        extraConfig = { diff.external = "difft"; };
    };
  };
}
