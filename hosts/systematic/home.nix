{
  pkgs,
  lib,
  ...
}: {
  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    fd
    tokei
  ];

  # Enable the custom base configuration from ./../../modules/default.nix
  base.enable = true;
  typesetters.typst.enable = lib.mkForce true;
  utils.git.profile = lib.mkForce "work";
  utils.cli.profile = lib.mkForce "extended";

  programs = {
    # Java
    java = {
      enable = true;
      package = pkgs.jdk11;
    };
    gradle.enable = true;
  };
}
