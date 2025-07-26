{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    utils.nix.enable = lib.mkEnableOption "enables nix utilities";
  };

  config = lib.mkIf config.utils.nix.enable {
    home.packages = with pkgs; [
      nix-prefetch-github
      nixfmt-classic
      alejandra
      nil
      nixd
    ];
  };
}
