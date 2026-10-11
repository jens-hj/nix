#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
manifest="$repo_root/modules/home/shell/zellij-plugins.json"
work_dir=$(mktemp -d)
trap 'rm -rf -- "$work_dir"' EXIT

for spec in 'dj95/zjstatus zjstatus.wasm' 'rvcas/room room.wasm' 'karimould/zellij-forgot zellij_forgot.wasm'; do
  read -r repository asset <<< "$spec"
  curl --fail --silent --show-error --location \
    "https://api.github.com/repos/$repository/releases/latest" > "$work_dir/release.json"
  version=$(jq -er '.tag_name' "$work_dir/release.json")
  url=$(jq -er --arg asset "$asset" '.assets[] | select(.name == $asset) | .browser_download_url' "$work_dir/release.json")
  curl --fail --silent --show-error --location "$url" -o "$work_dir/$asset"
  hash=$(nix hash file --type sha256 --sri "$work_dir/$asset")
  jq -n --arg name "$asset" --arg version "$version" --arg url "$url" --arg hash "$hash" \
    '{key: $name, value: {version: $version, url: $url, hash: $hash}}' > "$work_dir/$asset.json"
  printf '%s: %s\n' "$asset" "$version"
done

# Replace the manifest only after every release and download succeeds.
jq -s 'from_entries' "$work_dir/"*.wasm.json > "$work_dir/manifest.json"
cp -- "$work_dir/manifest.json" "$manifest"
