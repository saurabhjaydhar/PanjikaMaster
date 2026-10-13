#!/usr/bin/env bash
# Fail if a release APK is over the size budget (T-608, spec §3.3: app size < 30 MB).
# The universal APK carries every ABI, so it is an upper bound for what Play delivers
# from the app bundle. Prints the largest entries so a regression is easy to place.
set -euo pipefail
apk="${1:?usage: check_apk_size.sh <app-release.apk> [budget-bytes]}"
budget="${2:-31457280}" # 30 MiB
[ -f "$apk" ] || { echo "no such file: $apk"; exit 2; }
size=$(stat -c %s "$apk")
mb() { awk -v b="$1" 'BEGIN { printf "%.1f MB", b / 1048576 }'; }
report="APK size: $(mb "$size") (budget $(mb "$budget"))"
echo "$report"
echo "Largest entries (compressed):"
unzip -v "$apk" | awk 'NF >= 8 && $1 ~ /^[0-9]+$/ { print $3, $8 }' | sort -rn | awk 'NR <= 10' |
  while read -r bytes name; do printf '  %10s  %s\n' "$(mb "$bytes")" "$name"; done
if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then echo "### $report" >> "$GITHUB_STEP_SUMMARY"; fi
if [ "$size" -gt "$budget" ]; then
  echo "FAIL: over budget"
  exit 1
fi
echo "OK"
