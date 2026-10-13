# Assets

Source and licence of every font, icon, image and illustration (PRD §19.1 L6, L7, L13).

| Asset | Source | Licence | Used where | Notes |
|---|---|---|---|---|
| Tiro Bangla 1.52 | Tiro Typeworks, via github.com/google/fonts `ofl/tirobangla` | SIL OFL 1.1 | Display/headline/title type, both scripts (covers Bengali, Latin and all IAST diacritics, so no Noto Serif fallback is needed) | Subset by `scripts/build_fonts.sh` (182 KB); OFL text bundled and registered on the licences page. None of the three licences declares a Reserved Font Name, so the subset files may keep their names (checked 2026-10-12) |
| Noto Sans Bengali 3.011 | Google (Noto), via github.com/google/fonts `ofl/notosansbengali` | SIL OFL 1.1 | Bengali body/label/caption | Static 400/500/600 instances of the variable font, subset (~120 KB each) |
| Noto Sans 2.015 | Google (Noto), via github.com/google/fonts `ofl/notosans` | SIL OFL 1.1 | English body/label/caption | Static 400/500/600 instances, subset (~82 KB each). Fonts total 788 KB of the 1.5 MB budget |
| Material Symbols Rounded | Google | Apache-2.0 | UI icons | Planned (PRD §12.9) |
| Launcher icons (`app/android/app/src/main/res/mipmap-*`) | Flutter project template | BSD-3-Clause (Flutter) | Android launcher | **Placeholder** until the real icon (T-216) |
