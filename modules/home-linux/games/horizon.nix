{
  config,
  lib,
  pkgs,
  ...
}: {
  options.games.horizon.enable = lib.mkEnableOption "Enable the Horizon launcher";

  config = lib.mkIf config.games.horizon.enable {
    home.packages = [(pkgs.callPackage ./horizon-package.nix {})];
  };
}
