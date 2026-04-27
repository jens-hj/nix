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
    ./utils/code-stats.nix

    # Shell
    ./shell/fish.nix
    ./shell/zellij.nix

    # Typesetters
    ./typesetters/typst.nix

    # Editor
    ./editor/helix.nix
    ./editor/zed.nix
    ./editor/vscode.nix

    # Terminal
    ./terminal/ghostty.nix

    # Languages
    ./lang/flutter.nix

    # Visuals
    ./visuals/fonts.nix

    # Games
    ./games/minecraft.nix
  ];

  options = {
    base.enable = lib.mkEnableOption "enables fish, zellij, helix, and git configurations";
    games.enable = lib.mkEnableOption "enables games; minecraft";
  };

  config = lib.mkMerge [
    {
      programs = {
        # Enable home-manager itself
        home-manager.enable = true;
      };
    }

    (lib.mkIf config.base.enable {
      # Utils
      utils.cli.enable = lib.mkDefault true;
      utils.nix.enable = lib.mkDefault true;
      utils.git.enable = lib.mkDefault true;
      utils.code-stats.enable = lib.mkDefault false;

      # Shell
      shell.fish.enable = lib.mkDefault true;
      shell.fish.zellij.autoStart = lib.mkDefault true;
      shell.brew.enable = lib.mkDefault false;
      shell.zellij.enable = lib.mkDefault true;

      # Typesetters
      typesetters.typst.enable = lib.mkDefault false;

      # Editor
      editor.helix.enable = lib.mkDefault true;
      editor.zed.enable = lib.mkDefault false;
      editor.vscode.enable = lib.mkDefault false;

      # Terminal
      terminal.ghostty.enable = lib.mkDefault false;

      # Languages
      lang.flutter.enable = lib.mkDefault false;

      # Visuals
      visuals.fonts.enable = lib.mkDefault true;
    })

    (lib.mkIf config.games.enable {
      games.minecraft.enable = lib.mkDefault true;
    })
  ];
}
