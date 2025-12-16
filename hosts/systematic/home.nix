{
  pkgs,
  lib,
  ...
}: {
  home.stateVersion = "24.05";

  # Enable the custom base configuration from ./../../modules/default.nix
  base.enable = true;
  typesetters.typst.enable = lib.mkForce true;
  utils.git.profile = lib.mkForce "work";
  utils.cli.profile = lib.mkForce "extended";

  visuals.theme.enable = lib.mkForce false;

  programs = {
    # Java
    java = {
      enable = true;
      package = pkgs.jdk11;
    };
    gradle.enable = true;
  };
}
