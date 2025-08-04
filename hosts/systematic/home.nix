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
  utils.git.profile = lib.mkForce "work";
  utils.cli.profile = lib.mkForce "extended";

  programs = {
    # Enable home-manager itself
    home-manager.enable = true;
    # Java
    java = {
      enable = true;
      package = pkgs.jdk11;
    };
    gradle.enable = true;
  };
}
