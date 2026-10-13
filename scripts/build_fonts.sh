#!/usr/bin/env bash
# Rebuild app/assets/fonts from Google Fonts' official repository (T-109, spec §12.3).
# Static instances (400/500/600) of the variable Noto fonts, subset to Bengali + Latin
# (incl. IAST diacritics), keeping every OpenType layout feature Bengali shaping needs.
# Requires: uvx (fonttools). Licences: SIL OFL 1.1 (copied next to the fonts).
set -euo pipefail
OUT="$(cd "$(dirname "$0")/.." && pwd)/app/assets/fonts"
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
BASE=https://raw.githubusercontent.com/google/fonts/main/ofl
UNICODES="U+0020-007E,U+00A0-00FF,U+0100-017F,U+1E00-1EFF,U+0980-09FF,U+0964-0965,U+200B-200D,U+25CC,U+2010-2027,U+2030-203A,U+20B9,U+2212,U+2190-2193,U+2713"
ft() { uvx --quiet --from fonttools "$@"; }
subset() { ft pyftsubset "$1" --unicodes="$UNICODES" --layout-features='*' --no-hinting --desubroutinize --output-file="$2"; }

cd "$WORK"
curl -sSfL -o tiro.ttf "$BASE/tirobangla/TiroBangla-Regular.ttf"
curl -sSfL -o nsb.ttf "$BASE/notosansbengali/NotoSansBengali%5Bwdth,wght%5D.ttf"
curl -sSfL -o ns.ttf "$BASE/notosans/NotoSans%5Bwdth,wght%5D.ttf"
for f in tirobangla notosansbengali notosans; do curl -sSfL -o "OFL-$f.txt" "$BASE/$f/OFL.txt"; done

subset tiro.ttf "$OUT/TiroBangla-Regular.ttf"
for pair in 400:Regular 500:Medium 600:SemiBold; do
  w=${pair%%:*}; n=${pair##*:}
  ft fonttools varLib.instancer nsb.ttf wght="$w" wdth=100 -q -o "nsb-$w.ttf"
  ft fonttools varLib.instancer ns.ttf wght="$w" wdth=100 -q -o "ns-$w.ttf"
  subset "nsb-$w.ttf" "$OUT/NotoSansBengali-$n.ttf"
  subset "ns-$w.ttf" "$OUT/NotoSans-$n.ttf"
done
cp OFL-tirobangla.txt "$OUT/OFL-TiroBangla.txt"
cp OFL-notosansbengali.txt "$OUT/OFL-NotoSansBengali.txt"
cp OFL-notosans.txt "$OUT/OFL-NotoSans.txt"
du -ch "$OUT"/*.ttf | tail -1
