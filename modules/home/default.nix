{
  config,
  lib,
  ...
}: {
  imports = [
    ./shell/fish.nix
    ./shell/zellij.nix
    ./editor/helix.nix
    ./other/base.nix
    ./other/git.nix
    ./terminal/ghostty.nix
  ];

  options = {
    base.enable =
      lib.mkEnableOption "enables fish, zellij, helix, and git configurations";
  };

  config = lib.mkIf config.base.enable {
    fish.enable = lib.mkDefault true;
    zellij.enable = lib.mkDefault true;
    helix.enable = lib.mkDefault true;
    base-pkgs.enable = lib.mkDefault true;
    git.enable = lib.mkDefault true;
    ghostty.enable = lib.mkDefault false;
  };
}
