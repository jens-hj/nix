#!/usr/bin/env bash
set -euo pipefail

PROFILE=/nix/var/nix/profiles/system
DRY_RUN=false

# Self-elevate
if [[ $EUID -ne 0 ]]; then
  exec sudo "$0" "$@"
fi

usage() {
  echo "Usage: $0 [--dry-run]"
  exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    *)
      usage
      ;;
  esac
done

# List all generations
GENS_RAW=$(nix-env --list-generations --profile "$PROFILE")

mapfile -t ALL_GENS < <(
  echo "$GENS_RAW" | awk '{print $1}'
)

# Compute generations to keep (every 5th)
mapfile -t KEEP_GENS < <(
  printf '%s\n' "${ALL_GENS[@]}" | awk '$1 % 5 == 0'
)

# Find current generation (from running system)
CURRENT_GEN=$(readlink /nix/var/nix/profiles/system | awk -F'-' '{print $(NF-1)}')

# Ensure current generation is in KEEP_GENS
if ! printf '%s\n' "${KEEP_GENS[@]}" | grep -qx "$CURRENT_GEN"; then
    KEEP_GENS+=("$CURRENT_GEN")
fi

# Compute generations to delete (everything else)
mapfile -t DELETE_GENS < <(
  printf '%s\n' "${ALL_GENS[@]}" | grep -vxF -f <(printf '%s\n' "${KEEP_GENS[@]}")
)

join_by_comma() {
    local IFS=", "
    printf '%s' "${1}"
    shift
    for elem in "$@"; do
        printf ', %s' "$elem"
    done
    echo
}

echo "Generations to be kept:"
join_by_comma "${KEEP_GENS[@]}"

echo
echo "Generations to be deleted:"
join_by_comma "${DELETE_GENS[@]}"

if [[ "$DRY_RUN" == true ]]; then
  echo
  echo "Dry run enabled —  no changes made."
  exit 0
fi

nix-env --delete-generations --profile "$PROFILE" "${DELETE_GENS[@]}"
nix-collect-garbage

echo
echo "Cleanup complete."

