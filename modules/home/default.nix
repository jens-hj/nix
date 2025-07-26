{
  config,
  lib,
  ...
}: {
  imports = [
    ./shell/fish.nix
    ./shell/zellij.nix
    ./editor/helix.nix
    ./other/git.nix
    ./utils/sh.nix
    ./utils/nix.nix
    ./terminal/ghostty.nix
  ];

  options = {
    base.enable =
      lib.mkEnableOption "enables fish, zellij, helix, and git configurations";
  };

  config = lib.mkIf config.base.enable {
    # Utils
    utils.sh.enable = lib.mkDefault true;
    utils.nix.enable = lib.mkDefault true;
    utils.git.enable = lib.mkDefault true;

    # Shell
    shell.fish.enable = lib.mkDefault true;
    shell.brew.enable = lib.mkDefault false;
    shell.zellij.enable = lib.mkDefault true;

    # Editor
    editor.helix.enable = lib.mkDefault true;

    # Terminal
    terminal.ghostty.enable = lib.mkDefault false;
  };
}
