{
  lib,
  stdenvNoCC,
  coreutils,
  findutils,
  gnugrep,
  jq,
}:
stdenvNoCC.mkDerivation {
  pname = "noctalia-ai-usage";
  version = "0.1.0";

  src = ./noctalia-ai-usage;

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # The plugin registry scans a source root exactly one level deep for
    # <root>/<dir>/plugin.toml, so the plugin has to live in a subdirectory
    # rather than at $out itself.
    mkdir -p $out/ai-usage
    cp -r . $out/ai-usage/

    # The shell snippets run under whatever PATH the compositor handed noctalia,
    # which is not something this plugin should depend on — pin the absolute
    # store paths instead.
    substituteInPlace $out/ai-usage/*.luau \
      --subst-var-by coreutils ${coreutils}/bin \
      --subst-var-by grep ${lib.getExe' gnugrep "grep"} \
      --subst-var-by find ${lib.getExe' findutils "find"} \
      --subst-var-by xargs ${lib.getExe' findutils "xargs"} \
      --subst-var-by jq ${lib.getExe jq}

    runHook postInstall
  '';

  meta = {
    description = "Noctalia bar plugin showing remaining Claude Code and Codex quota";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
