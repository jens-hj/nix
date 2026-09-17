{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  options = {
    terminal.termy.enable = lib.mkEnableOption "enable the termy terminal";
  };

  config = lib.mkIf config.terminal.termy.enable {
    # Upstream has no home-manager module; the flake only exposes the package.
    home.packages = [inputs.termy.packages.${pkgs.stdenv.hostPlatform.system}.termy];
  };
}
