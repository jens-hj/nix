{
  config,
  lib,
  ...
}: {
  imports = [
    # Utils
    ./utils/git.nix
    ./utils/cli.nix
    ./utils/nix.nix

    # Shell
    ./shell/fish.nix
    ./shell/zellij.nix

    # Typesetters
    ./typesetters/typst.nix

    # Editor
    ./editor/helix.nix

    # Terminal
    ./terminal/ghostty.nix

    # Languages
    ./lang/flutter.nix

    # Visuals
    ./visuals/fonts.nix
    ./visuals/theme.nix
  ];

  options = {
    base.enable =
      lib.mkEnableOption "enables fish, zellij, helix, and git configurations";
  };

  config = lib.mkIf config.base.enable {
    programs = {
      # Enable home-manager itself
      home-manager.enable = true;
    };

    # Utils
    utils.cli.enable = lib.mkDefault true;
    utils.nix.enable = lib.mkDefault true;
    utils.git.enable = lib.mkDefault true;

    # Shell
    shell.fish.enable = lib.mkDefault true;
    shell.brew.enable = lib.mkDefault false;
    shell.zellij.enable = lib.mkDefault true;

    # Typesetters
    typesetters.typst.enable = lib.mkDefault false;

    # Editor
    editor.helix.enable = lib.mkDefault true;

    # Terminal
    terminal.ghostty.enable = lib.mkDefault false;

    # Languages
    lang.flutter.enable = lib.mkDefault false;

    # Visuals
    visuals.fonts.enable = lib.mkDefault true;
    visuals.theme.enable = lib.mkDefault true;
  };
}
