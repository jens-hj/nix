{
  config,
  lib,
  pkgs,
  ...
}: let
  mkCraftApp = pkgs.callPackage ./package.nix {};

  # Versions and hashes live in sources.json; refresh them with ./update.sh.
  sources = lib.importJSON ./sources.json;

  apps = {
    vectorcraft = {
      name = "VectorCraft vector graphics editor";
      description = "Native vector graphics editor with SVG and PDF support";
    };
    cadcraft = {
      name = "CADCraft computer-aided design and drafting";
      description = "Native AutoCAD-style computer-aided design and drafting app";
    };
    pdfcraft = {
      name = "PdfCraft PDF reader and editor";
      description = "Native PDF reader and editor";
    };
    figcraft = {
      name = "FigCraft interface design and prototyping";
      description = "Native interface design and prototyping tool";
    };
    effectcraft = {
      name = "EffectCraft motion graphics and compositing";
      description = "Native motion graphics and compositing tool";
    };
    photocraft = {
      name = "PhotoCraft photo editor";
      description = "Native photo editor";
    };
    lightcraft = {
      name = "LightCraft non-destructive photo editor";
      description = "Native non-destructive photo editor";
    };
    filmcraft = {
      name = "FilmCraft nonlinear video editor";
      description = "Native nonlinear video editor";
    };
    soundcraft = {
      name = "SoundCraft digital audio workstation";
      description = "Native Pro Tools-style digital audio workstation";
    };
    designcraft = {
      name = "DesignCraft page and layout design editor";
      description = "Native page and layout design editor";
    };
    wordcraft = {
      name = "WordCraft word processor";
      description = "Native Word-style word processor";
    };
    deckcraft = {
      name = "DeckCraft presentation editor";
      description = "Native PowerPoint-style presentation editor";
    };
    gridcraft = {
      name = "GridCraft spreadsheet";
      description = "Native Excel-style spreadsheet";
    };
    # Lists the suite and opens installed apps; its own installer expects
    # apt/dnf/Flatpak/AppImage, so install apps through these options instead.
    launcher = {
      name = "ArtCraft Launcher for the Craft App Suite";
      description = "Launcher and update checker for the Craft App Suite";
      homepage = "https://github.com/storytold/craft-launcher";
    };
  };
in {
  options.craft = lib.mapAttrs (key: app: {
    enable = lib.mkEnableOption app.name;
    package = lib.mkOption {
      type = lib.types.package;
      default = mkCraftApp ({
          inherit (sources.${key}) pname repo version hashes;
          inherit (app) description;
        }
        // lib.optionalAttrs (app ? homepage) {inherit (app) homepage;});
      defaultText = lib.literalMD "the ${app.name} release from `sources.json`";
      description = "Package to install for ${app.name}.";
    };
  })
  apps;

  config.home.packages = lib.concatLists (lib.mapAttrsToList (
      key: _: lib.optional config.craft.${key}.enable config.craft.${key}.package
    )
    apps);
}
