{
  lib,
  stdenv,
  alsa-lib,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  fontconfig,
  libGL,
  libx11,
  libxcursor,
  libxi,
  libxrandr,
  libxkbcommon,
  vulkan-loader,
  wayland,
}:
# Builds one of the storytold Craft apps from its prebuilt Linux release tarball.
{
  pname,
  version,
  hashes,
  description,
  repo ? pname,
  homepage ? "https://getartcraft.com/apps/${pname}",
}: let
  arches = {
    x86_64-linux = "x86_64";
    aarch64-linux = "aarch64";
  };
  system = stdenv.hostPlatform.system;
in
  stdenv.mkDerivation {
    inherit pname version;

    src = fetchurl {
      url = "https://github.com/storytold/${repo}/releases/download/v${version}/${pname}-${version}-linux-${arches.${system}}.tar.gz";
      hash = hashes.${system};
    };

    nativeBuildInputs = [autoPatchelfHook makeWrapper];
    # alsa-lib covers the apps with audio playback (EffectCraft, FilmCraft, ...).
    buildInputs = [stdenv.cc.cc.lib alsa-lib];

    dontConfigure = true;
    dontBuild = true;
    dontStrip = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r bin share $out/
      runHook postInstall
    '';

    # The native windowing and rendering backends load these libraries at runtime.
    postFixup = ''
      wrapProgram $out/bin/${pname} \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [
        fontconfig
        libGL
        libx11
        libxcursor
        libxi
        libxrandr
        libxkbcommon
        vulkan-loader
        wayland
      ]}"
    '';

    meta = {
      inherit description homepage;
      license = with lib.licenses; [asl20 mit];
      platforms = builtins.attrNames hashes;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      mainProgram = pname;
    };
  }
