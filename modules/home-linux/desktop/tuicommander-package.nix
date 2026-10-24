{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  autoPatchelfHook,
  wrapGAppsHook3,
  makeWrapper,
  # The AppImage bundles a WebKitGTK that cannot create an EGL display on this
  # system (aborts with EGL_BAD_PARAMETER before the webview ever paints, which
  # shows up as a black window). Every bundled .so is therefore discarded and
  # the binaries are patchelf'd against nixpkgs libraries instead — nixpkgs'
  # WebKitGTK initialises EGL here without complaint.
  webkitgtk_4_1,
  gtk3,
  glib,
  glib-networking,
  gsettings-desktop-schemas,
  gst_all_1,
  dbus,
  openssl,
  libsoup_3,
  cairo,
  pango,
  gdk-pixbuf,
  atk,
  at-spi2-atk,
  at-spi2-core,
  harfbuzz,
  fribidi,
  libthai,
  libdatrie,
  freetype,
  fontconfig,
  libxml2,
  libsecret,
  icu,
  sqlite,
  libepoxy,
  libdrm,
  libgbm,
  wayland,
  libxkbcommon,
  libx11,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxcb,
  libxi,
  libxcursor,
  libxrender,
  libxtst,
  libxau,
  libxdmcp,
  nss,
  nspr,
  libjpeg,
  libwebp,
  libpng,
  zlib,
  enchant,
  hyphen,
  woff2,
  lcms2,
  libtasn1,
  krb5,
  e2fsprogs,
  libgcrypt,
  libgpg-error,
  systemd,
  libselinux,
  pcre2,
  util-linux,
  libtiff,
  librsvg,
  libnotify,
  expat,
  bzip2,
  brotli,
  graphite2,
  alsa-lib,
  libglvnd,
  libayatana-appindicator,
  libdbusmenu,
  xdg-utils,
}: let
  pname = "tuicommander";
  version = "1.7.1";

  src = fetchurl {
    url = "https://github.com/sstraus/tuicommander/releases/download/v${version}/TUICommander_${version}_amd64.AppImage";
    hash = "sha256-XKH22XAnI7bXnsycTURxVzYY00U5SoYgl402Bs0zwSc=";
  };

  extracted = appimageTools.extract {inherit pname version src;};

  gstPlugins = with gst_all_1; [
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
  ];
in
  stdenv.mkDerivation {
    inherit pname version;
    src = extracted;

    nativeBuildInputs = [autoPatchelfHook wrapGAppsHook3 makeWrapper];

    buildInputs =
      [
        webkitgtk_4_1
        gtk3
        glib
        gsettings-desktop-schemas
        dbus
        openssl
        libsoup_3
        cairo
        pango
        gdk-pixbuf
        atk
        at-spi2-atk
        at-spi2-core
        harfbuzz
        fribidi
        libthai
        libdatrie
        freetype
        fontconfig
        libxml2
        libsecret
        icu
        sqlite
        libepoxy
        libdrm
        libgbm
        wayland
        libxkbcommon
        nss
        nspr
        libjpeg
        libwebp
        libpng
        zlib
        enchant
        hyphen
        woff2
        lcms2
        libtasn1
        krb5
        e2fsprogs
        libgcrypt
        libgpg-error
        systemd
        libselinux
        pcre2
        util-linux
        libtiff
        librsvg
        libnotify
        expat
        bzip2
        brotli
        graphite2
        alsa-lib
        libglvnd
        libayatana-appindicator
        libdbusmenu
        stdenv.cc.cc.lib
      ]
      ++ gstPlugins
      ++ (with gst_all_1; [gstreamer])
      ++ [
        libx11
        libxcomposite
        libxdamage
        libxext
        libxfixes
        libxrandr
        libxcb
        libxi
        libxcursor
        libxrender
        libxtst
        libxau
        libxdmcp
      ];

    dontConfigure = true;
    dontBuild = true;
    # Stripping these prebuilt binaries makes them segfault on startup.
    dontStrip = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin $out/share
      # Only the application's own executables — no bundled libraries, and not
      # the vendored xdg-open/xdg-mime shims (xdg-utils is on PATH instead).
      for exe in tuicommander tuic tuic-bridge tuic-remote; do
        install -Dm755 usr/bin/$exe $out/bin/$exe
      done

      cp -r usr/share/glib-2.0 usr/share/icons $out/share/
      # Upstream ships an empty Categories= line, which leaves the entry
      # uncategorised in application launchers.
      install -Dm644 TUICommander.desktop $out/share/applications/TUICommander.desktop
      substituteInPlace $out/share/applications/TUICommander.desktop \
        --replace-fail 'Categories=' 'Categories=Development;Utility;'
      install -Dm644 tuicommander.png $out/share/icons/hicolor/256x256/apps/tuicommander.png

      runHook postInstall
    '';

    # The upstream AppRun forces GDK_BACKEND=x11 because the Wayland backend
    # crashes this Tauri app (tauri-apps/tauri#8541); keep that behaviour.
    preFixup = ''
      gappsWrapperArgs+=(
        --set GDK_BACKEND x11
        --prefix PATH : "${lib.makeBinPath [xdg-utils]}"
        --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "${lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" gstPlugins}"
        --prefix GIO_EXTRA_MODULES : "${glib-networking}/lib/gio/modules"
      )
    '';

    meta = {
      description = "Native platform for AI coding agents";
      homepage = "https://tuicommander.com";
      platforms = ["x86_64-linux"];
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      mainProgram = "tuicommander";
    };
  }
