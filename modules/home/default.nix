{ pkgs, config, lib, ... }:
{
  imports = [
    ./shell/fish.nix
    ./shell/zellij.nix
    ./editor/helix.nix
    ./other/git.nix
  ];

  options = {
    base.enable = lib.mkEnableOption "enables fish, zellij, helix, and git configurations";
  };

  config = lib.mkIf config.base.enable {
    fish.enable = true;
    zellij.enable = true;
    helix.enable = true;
    git.enable = true;
  };
}
