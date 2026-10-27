{
  lib,
  stdenvNoCC,
  fetchurl,
  buildFHSEnv,
  makeWrapper,
  makeDesktopItem,
}: let
  version = "0.2.16";
  launcher = stdenvNoCC.mkDerivation {
    pname = "horizon-launcher-unwrapped";
    inherit version;
    src = fetchurl {
      url = "https://github.com/horizon-rust/horizon/releases/download/launcher%40${version}/horizon-launcher-linux-x86_64.tar.gz";
      hash = "sha256-0x+WEPjZP4KT0sxelcAuZPIBGunBbZAE3N4rKOSOypM=";
    };
    sourceRoot = ".";
    dontBuild = true;
    dontFixup = true;
    installPhase = ''
      runHook preInstall
      install -Dm755 horizon-launcher $out/libexec/horizon-launcher
      runHook postInstall
    '';
  };
  desktopItem = makeDesktopItem {
    name = "horizon-launcher";
    desktopName = "Horizon";
    comment = "Install and play Horizon";
    exec = "horizon-launcher";
    icon = "applications-games";
    categories = ["Game"];
    startupWMClass = "horizon-launcher";
  };
in
  buildFHSEnv {
    pname = "horizon-launcher";
    inherit version;
    # Keep downloaded clients/preparers in the same environment as the launcher.
    # Patching only the packaged launcher would leave those binaries unable to run.
    targetPkgs = pkgs:
      with pkgs; [
        alsa-lib
        dbus
        fontconfig
        freetype
        jdk25
        libGL
        libx11
        libxcursor
        libxi
        libxrandr
        libxcb
        libxkbcommon
        openssl
        python3
        stdenv.cc.cc.lib
        udev
        vulkan-loader
        wayland
        xdg-utils
        zlib
      ];
    multiPkgs = null;
    nativeBuildInputs = [makeWrapper];
    runScript = "${launcher}/libexec/horizon-launcher";
    extraInstallCommands = ''
      mv $out/bin/horizon-launcher $out/bin/.horizon-launcher-fhs
      makeWrapper $out/bin/.horizon-launcher-fhs $out/bin/horizon-launcher \
        --set HORIZON_LAUNCHER_NO_SELF_UPDATE 1 \
        --set HORIZON_LAUNCHER_DESKTOP_EXEC $out/bin/horizon-launcher
      mkdir -p $out/share/applications
      cp ${desktopItem}/share/applications/* $out/share/applications/
    '';
    meta = {
      description = "Launcher for Horizon, a Rust rewrite of Minecraft Java Edition";
      homepage = "https://playhorizon.dev/";
      license = lib.licenses.mit;
      platforms = ["x86_64-linux"];
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
