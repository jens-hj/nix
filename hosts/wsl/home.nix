{...}: {
  imports = [
    ../../modules/home
  ];

  home.stateVersion = "26.05";
  home.sessionVariables.NIXOS_DEFAULT_CONFIG = "wsl";
  base.enable = true;
  utils.cli.profile = "extended";
  utils.git.profile = "personal";
  shell.fish.zellij.autoStart = false;
  programs.helix.settings.theme = "catppuccin_mocha";

  programs.direnv.nix-direnv.enable = true;

  programs.fish = {
    interactiveShellInit = ''
      # Catppuccin Mocha, using terminal colors without desktop theming.
      set -g fish_color_normal cdd6f4
      set -g fish_color_command 89b4fa
      set -g fish_color_param f2cdcd
      set -g fish_color_quote a6e3a1
      set -g fish_color_redirection f5c2e7
      set -g fish_color_end fab387
      set -g fish_color_error f38ba8
      set -g fish_color_comment 6c7086
      set -g fish_color_autosuggestion 6c7086
      set -g fish_color_search_match --background=313244
      set -g fish_color_selection --background=313244
      set -g fish_pager_color_prefix 89b4fa
      set -g fish_pager_color_completion cdd6f4
      set -g fish_pager_color_description 6c7086
      set -g fish_pager_color_selected_background --background=313244
    '';
  };
}
