{
  pkgs,
  config,
  lib,
  ...
}:
{
  options = {
    editor.zed.enable = lib.mkEnableOption "enables custom configured helix";
  };

  config = lib.mkIf config.editor.zed.enable {
    programs.zed-editor = {
      enable = true;
      extensions = [
        "catppuccin"
        "catppuccin-blur"
        "catppuccin-icons"
        "html"
        "scss"
        "nix"
        "fish"
        "json5"
        "csv"
        "toml"
        "ron"
        "typst"
        "cargo-tom"
        "just"
        "git-firefly"
        "code-stats"
        "color-highlight"
        "dockerfile"
        "sql"
        "svelte"
        "svelte-snippets"
        "docker-compose"
        "env"
        "codebook"
        "wgsl-wesl"
      ];
      userSettings = {
        theme = {
          mode = "system";
          dark = lib.mkForce "Catppuccin Mocha";
          light = lib.mkForce "Catppuccin Latte";
        };
        icon_theme = "Catppuccin Mocha";
        telemetry = {
          diagnostics = false;
          metrics = false;
        };
        # languages = {
        #   "Nix" = {
        #     language_servers = [ "nil" "!nixd" ];

        #   };
        # };
        ui_font_size = 24;
        buffer_font_size = 24;
        wrap_guides = [
          80
          100
        ];
        indent_guides = {
          enabled = true;
          coloring = "indent_aware";
          active_line_width = 2;
          background_coloring = "disabled";
        };
        title_bar = {
          show_branch_icon = true;
        };
        helix_mode = false;
        active_pane_modifiers = {
          border_size = 1.0;
          inactive_opacity = 0.5;
        };
        bottom_dock_layout = "right_aligned";
        toolbar = {
          breadcrumbs = true;
          quick_actions = true;
          selections_menu = true;
          agent_review = true;
          code_actions = true;
        };
        resize_all_panels_in_dock = [ "left" ];
        tabs = {
          git_status = true;
          close_position = "right";
          show_close_button = "hover";
          file_icons = true;
          show_diagnostics = "all";
        };
        inlay_hints = {
          enabled = false;
          show_type_hints = true;
          show_parameter_hints = true;
          show_other_hints = true;
          show_background = false;
          toggle_on_modifier_press = {
            alt = true;
          };
        };
        agent = {
          dock = "left";
          default_model = {
            provider = "copilot_chat";
            model = "claude-sonnet-4.5";
          };
          inline_assistant_model = {
            provider = "copilot_chat";
            model = "claude-sonnet-4.5";
          };
        };
        project_panel.dock = "right";
        outline_panel.dock = "right";
        notification_panel.dock = "left";
        chat_panel.dock = "left";
        git_panel.dock = "right";
        languages = {
          Nix = {
            language_servers = [
              "nil"
              "!nixd"
            ];
            formatter = {
              external = {
                command = "${pkgs.alejandra}/bin/alejandra";
              };
            };
          };
        };
        lsp_document_colors = "border";
      };
    };
  };
}
