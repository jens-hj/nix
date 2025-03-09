#!/usr/bin/env fish

# Read the JSON file
set json_file "github-fish-plugins.json"

# Load the JSON data
set plugins (cat $json_file | jq -c '.[]')

# Iterate over each plugin and generate NixOS configuration
for plugin in $plugins
    # Get the values from JSON
    set owner (echo $plugin | jq -r '.owner')
    set repo (echo $plugin | jq -r '.repo')

    # Retry prefetch up to 5 times if it fails
    set attempts 0
    while true
        set prefetch_output (nix-prefetch-github $owner $repo 2>/dev/null | jq -c '. | {rev: .rev, sha256: .hash}')
        if test "$status" -eq 0
            break
        end

        # Increment attempt counter
        set attempts (math $attempts + 1)
        if test $attempts -ge 5
            echo "Prefetch failed for $owner/$repo after 5 attempts. Skipping..."
            continue 2
        end
    end

    set rev (echo $prefetch_output | jq -r '.rev')
    set sha256 (echo $prefetch_output | jq -r '.sha256')

    # Skip if rev or sha256 is empty
    if test -z "$rev" -o -z "$sha256"
        echo "Prefetch failed for $owner/$repo. Skipping..."
        continue
    end

    # Format the NixOS configuration output
    set name (echo $repo | sed 's/.fish$//')
    echo "{
  name = \"$name\";
  src = pkgs.fetchFromGitHub {
    owner = \"$owner\";
    repo = \"$repo\";
    rev = \"$rev\";
    sha256 = \"$sha256\";
  };
}"
    sleep 0.5
end
