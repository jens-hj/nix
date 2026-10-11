{pkgs, ...}: {
  imports = [
    ../../modules/home/utils/cli.nix
    ../../modules/home/utils/git.nix
    ../../modules/home/utils/nix.nix
    ../../modules/home/editor/helix.nix
  ];

  home.stateVersion = "26.05";
  programs.home-manager.enable = true;

  utils.cli = {
    enable = true;
    profile = "extended";
  };
  utils.git = {
    enable = true;
    profile = "personal";
  };
  utils.nix.enable = true;
  editor.helix.enable = true;
  programs.helix.settings.theme = "catppuccin_mocha";

  home.packages = with pkgs; [eza tree sqlite pre-commit];

  programs.direnv.nix-direnv.enable = true;

  programs.fish = {
    enable = true;
    shellAbbrs = {
      lg = "lazygit";
      rf = "exec fish";
    };
    shellAliases = {
      ls = "eza --group-directories-first --classify --grid";
      ll = "eza --group-directories-first --classify --long --header --git";
      space = "duf --hide-fs squashfs";
      ns = "nix-search-tv print | fzf --preview 'nix-search-tv preview {}' --scheme history";
    };
    plugins = [
      {
        name = "pure";
        src = pkgs.fishPlugins.pure.src;
      }
      {
        name = "fzf-fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
    ];
    interactiveShellInit = ''
      set -g fish_greeting

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
