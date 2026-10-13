#!/usr/bin/env bash
# Fail if the app is over the size budget (T-608, PRD §3.3: app size < 30 MB).
# Play delivers one ABI per device from the app bundle, so the budget applies to each
# ABI's share of the universal release APK: the APK minus the other ABIs' native
# libraries (compressed sizes; zip overhead aside, this is the split APK's size).
# Prints the per-ABI sizes and the largest entries so a regression is easy to place.
set -euo pipefail
apk="${1:?usage: check_apk_size.sh <app-release.apk> [budget-bytes]}"
budget="${2:-31457280}" # 30 MiB
[ -f "$apk" ] || { echo "no such file: $apk"; exit 2; }
total=$(stat -c %s "$apk")
mb() { awk -v b="$1" 'BEGIN { printf "%.1f MB", b / 1048576 }'; }
# "<compressed bytes> <name>" for every entry.
entries=$(unzip -v "$apk" | awk 'NF >= 8 && $1 ~ /^[0-9]+$/ { print $3, $8 }')
abis=$(printf '%s\n' "$entries" | awk '$2 ~ /^lib\// { split($2, p, "/"); print p[2] }' | sort -u)

echo "Universal APK: $(mb "$total") (all ABIs; not what a device downloads)"
worst=0
summary=""
for abi in $abis; do
  others=$(printf '%s\n' "$entries" |
    awk -v abi="$abi" '$2 ~ /^lib\// { split($2, p, "/"); if (p[2] != abi) s += $1 } END { print s + 0 }')
  size=$((total - others))
  echo "  $abi: $(mb "$size")"
  summary="$summary $abi $(mb "$size");"
  [ "$size" -gt "$worst" ] && worst=$size
done
[ -z "$abis" ] && worst=$total
echo "Largest entries (compressed):"
printf '%s\n' "$entries" | sort -rn | awk 'NR <= 10' |
  while read -r bytes name; do printf '  %10s  %s\n' "$(mb "$bytes")" "$name"; done

report="Per-ABI app size: largest $(mb "$worst") (budget $(mb "$budget")) —$summary"
echo "$report"
if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then echo "### $report" >> "$GITHUB_STEP_SUMMARY"; fi
if [ "$worst" -gt "$budget" ]; then
  echo "FAIL: over budget"
  exit 1
fi
echo "OK"
