#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq
# Bumps every Craft app in sources.json to its latest GitHub release, taking
# hashes from the release's SHA256SUMS.txt so nothing has to be downloaded.
# Usage: ./update.sh [app ...]   (defaults to all apps)
set -euo pipefail

cd "$(dirname "$0")"
sources=sources.json
apps=("$@")
[ ${#apps[@]} -eq 0 ] && mapfile -t apps < <(jq -r 'keys[]' "$sources")

auth=()
[ -n "${GITHUB_TOKEN:-}" ] && auth=(-H "Authorization: Bearer $GITHUB_TOKEN")

for app in "${apps[@]}"; do
  pname=$(jq -r --arg a "$app" '.[$a].pname' "$sources")
  repo=$(jq -r --arg a "$app" '.[$a].repo' "$sources")
  current=$(jq -r --arg a "$app" '.[$a].version' "$sources")

  tag=$(curl -fsSL "${auth[@]}" "https://api.github.com/repos/storytold/$repo/releases/latest" | jq -r .tag_name)
  version=${tag#v}
  if [ "$version" = "$current" ]; then
    echo "$app: $current (up to date)"
    continue
  fi

  sums=$(curl -fsSL "https://github.com/storytold/$repo/releases/download/$tag/SHA256SUMS.txt")
  sri() {
    local hex
    hex=$(awk -v f="$pname-$version-linux-$1.tar.gz" '$2 == f || $2 == "*" f {print $1}' <<<"$sums")
    [ -n "$hex" ] || { echo "$app: no $1 tarball in $tag" >&2; exit 1; }
    nix hash convert --hash-algo sha256 --to sri "$hex"
  }
  x86=$(sri x86_64)
  arm=$(sri aarch64)

  jq --arg a "$app" --arg v "$version" --arg x "$x86" --arg r "$arm" \
    '.[$a].version = $v | .[$a].hashes = {"x86_64-linux": $x, "aarch64-linux": $r}' \
    "$sources" >"$sources.tmp"
  mv "$sources.tmp" "$sources"
  echo "$app: $current -> $version"
done
