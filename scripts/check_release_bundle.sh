#!/usr/bin/env bash
# Fail if a release APK/AAB contains sample (fixture) data (T-113, spec §6.8).
# Sample packs carry this marker in packs.validation_summary (data/pack/sample.py).
set -euo pipefail
MARKER="PANJIKA-SAMPLE-FIXTURE-DO-NOT-SHIP"
bundle="${1:?usage: check_release_bundle.sh <app-release.apk|.aab>}"
[ -f "$bundle" ] || { echo "no such file: $bundle"; exit 2; }

# Search every entry, uncompressed, including native libs and assets. Count matches
# instead of `grep -q`: under pipefail, grep -q exiting early makes unzip die of SIGPIPE,
# which turned a match into a pipeline failure and the check into a false "OK".
hits=$(unzip -p "$bundle" | grep -a -c "$MARKER" || true)
if [ "${hits:-0}" -gt 0 ]; then
  echo "FAIL: $bundle contains sample data (marker $MARKER). Release builds must contain none."
  unzip -Z1 "$bundle" | while read -r entry; do
    n=$(unzip -p "$bundle" "$entry" 2>/dev/null | grep -a -c "$MARKER" || true)
    [ "${n:-0}" -gt 0 ] && echo "  in: $entry"
  done
  exit 1
fi
echo "OK: no sample marker in $bundle"
