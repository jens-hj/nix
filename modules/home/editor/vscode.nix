{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    editor.vscode.enable = lib.mkEnableOption "enables custom configured vscode";
  };

  config = lib.mkIf config.editor.vscode.enable {
    programs.vscode = {
      enable = true;
      # package = pkgs.vscode-insiders;
      profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          svelte.svelte-vscode
          rust-lang.rust-analyzer
          catppuccin.catppuccin-vsc
          catppuccin.catppuccin-vsc-icons
          docker.docker
          mechatroner.rainbow-csv
          # riussi.code-stats-vscode
          mkhl.direnv
          bbenoist.nix
          wgsl-analyzer.wgsl-analyzer
          a5huynh.vscode-ron
          eamodio.gitlens
          bmalehorn.vscode-fish
          # tenninebt.vscode-koverage
          # ryanluker.vscode-coverage-gutters
        ];
        # userSettings = {
        #   "editor.fontLigatures" = true;
        #   "editor.formatOnPaste" = true;
        #   "editor.formatOnSave" = true;
        #   "editor.formatOnType" = true;
        #   "editor.guides.bracketPairs" = true;
        #   "codestats.username" = "Avianastra";
        #   "codestats.apikey" =
        #     "SFMyNTY.UVhacFlXNWhjM1J5WVE9PSMjTWpZMU1URT0.CuaSxjkXPr1SEK1-mjQ7cUTxvyV2s0PXH26lhoMzX4Y";
        #   "svelte.enable-ts-plugin" = true;
        # };
      };
    };
  };
}
