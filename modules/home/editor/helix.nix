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
      languages.language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "${pkgs.nixfmt-classic}/bin/nixfmt";
        }
        {name = "kdl";}
      ];
      defaultEditor = true;
    };
  };
}
