{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    desktop.tuicommander.enable = lib.mkEnableOption "Enable TUICommander";
  };

  config = lib.mkIf config.desktop.tuicommander.enable {
    home.packages = [(pkgs.callPackage ./tuicommander-package.nix {})];
  };
}
