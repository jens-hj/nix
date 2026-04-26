{
  pkgs,
  config,
  lib,
  ...
}: {
  options = {
    editor.helix.enable = lib.mkEnableOption "enables custom configured helix";
  };

  config = lib.mkIf config.editor.helix.enable {
    programs.helix = {
      enable = true;
      settings = {
        editor.cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
      };
      languages = {
        language-server = {
          nixd = {
            command = "${pkgs.nixd}/bin/nixd";
          };

          # rust-analyzer = {
          #   command = "${pkgs.rust-analyzer}/bin/rust-analyzer";
          # };

          # # HTML/CSS/SCSS
          # vscode-html = {
          #   command = "${pkgs.vscode-langservers-extracted}/bin/vscode-html-language-server";
          #   args = [ "--stdio" ];
          # };
          # vscode-css = {
          #   command = "${pkgs.vscode-langservers-extracted}/bin/vscode-css-language-server";
          #   args = [ "--stdio" ];
          # };

          # # TS/JS
          # ts = {
          #   command = "${pkgs.typescript-language-server}/bin/typescript-language-server";
          #   args = [ "--stdio" ];
          # };

          # # Svelte
          # svelte = {
          #   command = "${pkgs.svelte-language-server}/bin/svelteserver";
          #   args = [ "--stdio" ];
          # };

          # # Python
          # pyright = {
          #   command = "${pkgs.pyright}/bin/pyright-langserver";
          #   args = [ "--stdio" ];
          # };
          # ruff = {
          #   command = "${pkgs.ruff}/bin/ruff";
          #   args = [ "--stdio" ];
          # };

          # # TOML
          # taplo = {
          #   command = "${pkgs.taplo}/bin/taplo";
          #   args = [
          #     "lsp"
          #     "stdio"
          #   ];
          # };

          # # JSON (also provides HTML/CSS if you already use it)
          # vscode-json = {
          #   command = "${pkgs.vscode-langservers-extracted}/bin/vscode-json-language-server";
          #   args = [ "--stdio" ];
          # };

          # # RON
          # ron = {
          #   command = "${pkgs.ron-lsp}/bin/ron-lsp";
          # };

          # # Markdown
          # marksman = {
          #   command = "${pkgs.marksman}/bin/marksman";
          # };
        };

        language = [
          {
            name = "nix";
            auto-format = true;
            formatter.command = "${pkgs.alejandra}/bin/alejandra";
            language-servers = ["nixd"];
          }

          # {
          #   name = "rust";
          #   auto-format = true;
          #   formatter.command = "${pkgs.rustfmt}/bin/rustfmt";
          #   formatter.args = [
          #     "--emit"
          #     "stdout"
          #   ];
          #   language-servers = [ "rust-analyzer" ];
          # }

          # {
          #   name = "html";
          #   auto-format = true;
          #   formatter.command = "${pkgs.nodePackages.prettier}/bin/prettier";
          #   formatter.args = [
          #     "--parser"
          #     "html"
          #   ];
          #   language-servers = [ "vscode-html" ];
          # }

          # {
          #   name = "css";
          #   auto-format = true;
          #   formatter.command = "${pkgs.nodePackages.prettier}/bin/prettier";
          #   formatter.args = [
          #     "--parser"
          #     "css"
          #   ];
          #   language-servers = [ "vscode-css" ];
          # }

          # {
          #   name = "scss";
          #   auto-format = true;
          #   formatter.command = "${pkgs.nodePackages.prettier}/bin/prettier";
          #   formatter.args = [
          #     "--parser"
          #     "scss"
          #   ];
          #   language-servers = [ "vscode-css" ];
          # }

          # {
          #   name = "javascript";
          #   auto-format = true;
          #   formatter.command = "${pkgs.nodePackages.prettier}/bin/prettier";
          #   formatter.args = [
          #     "--stdin-filepath"
          #     "%{buffer_name}"
          #   ];
          #   language-servers = [ "ts" ];
          # }
          # {
          #   name = "typescript";
          #   auto-format = true;
          #   formatter.command = "${pkgs.nodePackages.prettier}/bin/prettier";
          #   formatter.args = [
          #     "--stdin-filepath"
          #     "%{buffer_name}"
          #   ];
          #   language-servers = [ "ts" ];
          # }

          # {
          #   name = "jsx";
          #   auto-format = true;
          #   formatter.command = "${pkgs.nodePackages.prettier}/bin/prettier";
          #   formatter.args = [
          #     "--stdin-filepath"
          #     "%{buffer_name}"
          #   ];
          #   language-servers = [ "ts" ];
          # }

          # {
          #   name = "tsx";
          #   auto-format = true;
          #   formatter.command = "${pkgs.nodePackages.prettier}/bin/prettier";
          #   formatter.args = [
          #     "--stdin-filepath"
          #     "%{buffer_name}"
          #   ];
          #   language-servers = [ "ts" ];
          # }

          # {
          #   name = "svelte";
          #   auto-format = true;
          #   formatter.command = "${pkgs.nodePackages.prettier}/bin/prettier";
          #   formatter.args = [
          #     "--stdin-filepath"
          #     "%{buffer_name}"
          #   ];
          #   language-servers = [
          #     "svelte"
          #     "ts"
          #   ];
          # }

          # {
          #   name = "python";
          #   auto-format = true;
          #   formatter.command = "${pkgs.ruff}/bin/ruff";
          #   formatter.args = [
          #     "format"
          #     "-"
          #   ];
          #   language-servers = [
          #     "pyright"
          #     "ruff"
          #   ];
          # }
          # {
          #   name = "kdl";
          #   auto-format = true;
          #   formatter.command = "${pkgs.kdlfmt}/bin/kdlfmt";
          #   formatter.args = [
          #     "format"
          #     "-"
          #   ];
          #   # language-servers = [ "kdl" ];
          # }
          # {
          #   name = "toml";
          #   auto-format = true;
          #   language-servers = [ "taplo" ];
          #   formatter = {
          #     command = "${pkgs.taplo}/bin/taplo";
          #     args = [
          #       "format"
          #       "-"
          #     ];
          #   };
          # }
          # {
          #   name = "json";
          #   auto-format = true;
          #   language-servers = [ "vscode-json" ];
          #   formatter = {
          #     command = "${pkgs.nodePackages.prettier}/bin/prettier";
          #     args = [
          #       "--stdin-filepath"
          #       "%{buffer_name}"
          #     ];
          #   };
          # }
          # {
          #   name = "jsonc";
          #   auto-format = true;
          #   language-servers = [ "vscode-json" ];
          #   formatter = {
          #     command = "${pkgs.nodePackages.prettier}/bin/prettier";
          #     args = [
          #       "--stdin-filepath"
          #       "%{buffer_name}"
          #     ];
          #   };
          # }
          # {
          #   name = "json5";
          #   auto-format = true;
          #   language-servers = [ "vscode-json" ];
          #   formatter = {
          #     command = "${pkgs.nodePackages.prettier}/bin/prettier";
          #     args = [
          #       "--stdin-filepath"
          #       "%{buffer_name}"
          #     ];
          #   };
          # }
          # {
          #   name = "ron";
          #   auto-format = true; # no formatter exists
          #   language-servers = [ "ron" ];
          # }
          # {
          #   name = "markdown";
          #   auto-format = true;

          #   language-servers = [ "marksman" ];

          #   formatter = {
          #     command = "${pkgs.nodePackages.prettier}/bin/prettier";
          #     args = [
          #       "--stdin-filepath"
          #       "%{buffer_name}"
          #     ];
          #   };
          # }
        ];
      };
      defaultEditor = true;
    };
  };
}
