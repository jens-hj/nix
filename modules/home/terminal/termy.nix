{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  termy = inputs.termy.packages.${pkgs.stdenv.hostPlatform.system}.termy;

  # Upstream installs binaries only, so launchers reading XDG entries (vicinae)
  # cannot see termy. Ship the entry and icons as a separate derivation rather
  # than an overrideAttrs postInstall, which would force a full Rust rebuild.
  termyDesktop = pkgs.runCommand "termy-desktop-entry" {} ''
    install -Dm644 ${
      pkgs.makeDesktopItem {
        name = "termy";
        desktopName = "Termy";
        genericName = "Terminal Emulator";
        comment = "A fast, minimal terminal emulator";
        exec = "${termy}/bin/termy";
        icon = "termy";
        terminal = false;
        categories = ["System" "TerminalEmulator"];
        keywords = ["shell" "prompt" "command" "commandline" "cmd"];
        # Matches APP_ID in crates/desktop_app/src/main.rs, so the Wayland
        # window is associated with this entry.
        startupWMClass = "termy";
      }
    }/share/applications/termy.desktop -t $out/share/applications

    install -Dm644 ${inputs.termy}/assets/termy_icon.png \
      $out/share/icons/hicolor/512x512/apps/termy.png
    install -Dm644 '${inputs.termy}/assets/termy_icon@1024px.png' \
      $out/share/icons/hicolor/1024x1024/apps/termy.png
  '';
in {
  options = {
    terminal.termy.enable = lib.mkEnableOption "enable the termy terminal";
  };

  config = lib.mkIf config.terminal.termy.enable {
    # Upstream has no home-manager module; the flake only exposes the package.
    home.packages = [termy termyDesktop];
  };
}
