#!/usr/bin/env bash
# Fail if a release APK/AAB contains sample (fixture) data (T-113, spec §6.8).
# Sample packs carry this marker in packs.validation_summary (data/pack/sample.py).
set -euo pipefail
MARKER="PANJIKA-SAMPLE-FIXTURE-DO-NOT-SHIP"
bundle="${1:?usage: check_release_bundle.sh <app-release.apk|.aab>}"
[ -f "$bundle" ] || { echo "no such file: $bundle"; exit 2; }

# Search every entry, uncompressed, including native libs and assets.
if unzip -p "$bundle" | grep -a -q "$MARKER"; then
  echo "FAIL: $bundle contains sample data (marker $MARKER). Release builds must contain none."
  unzip -l "$bundle" | awk 'NR>3 {print $4}' | while read -r entry; do
    [ -n "$entry" ] && unzip -p "$bundle" "$entry" 2>/dev/null | grep -a -q "$MARKER" && echo "  in: $entry"
  done
  exit 1
fi
echo "OK: no sample marker in $bundle"
