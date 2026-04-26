{
  pkgs,
  lib,
  ...
}:
{
  home.stateVersion = "24.05";

  # Enable the custom base configuration from ./../../modules/default.nix
  base.enable = true;
  typesetters.typst.enable = lib.mkForce true;
  utils.git.profile = lib.mkForce "work";
  utils.cli.profile = lib.mkForce "extended";
  editor.zed.remote.enable = true;

  # visuals.theme.enable = lib.mkForce false;

  home.packages = with pkgs; [
    chromium
  ];

  programs = {
    # Java
    java = {
      enable = true;
      package = pkgs.jdk11;
    };
    gradle.enable = true;
  };

  home.sessionVariables = {
    CHROME_BIN = "${pkgs.chromium}/bin/chromium-browser";
  };
}
