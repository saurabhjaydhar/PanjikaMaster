#!/usr/bin/env python3
"""Localisation checks for the app (T-107, spec §13.5). Run by ci-app.yml.

1. app_bn.arb (source) and app_en.arb have identical message keys.
2. Every message uses the same placeholders in both languages.
3. Every source message has an @description; no message is empty.
4. No English message is identical to its Bengali one, unless whitelisted or it has no
   words at all (a pure layout pattern such as '{name} · {until}').
5. No hard-coded UI strings in Dart widgets (Text('...'), label: '...', …).
   A deliberate exception is marked with `// l10n-ok: <reason>` on that line.
"""

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
APP = ROOT / "app"
L10N = APP / "lib" / "l10n"
SAME_IN_BOTH = {"timeZoneLabel", "sampleWatermark", "languageNameBengali", "languageNameEnglish"}  # identical on purpose (see @description)

# A placeholder is {name} or {name, plural|select, …}; a plural/select branch like =0{…} or
# other{…} is message text, so its brace follows a selector character and is skipped.
PLACEHOLDER = re.compile(r"(?<![\w=])\{([A-Za-z_]\w*)\s*[,}]", re.ASCII)
LITERAL_PATTERNS = [
    re.compile(r"""\bText\(\s*(['"])(?!\1)"""),  # Text('...') with a non-empty literal
    re.compile(r"""\bTextSpan\([^)]*\btext:\s*(['"])(?!\1)"""),
    re.compile(
        r"""\b(label|labelText|hintText|helperText|semanticsLabel|tooltip|title|message)"""
        r""":\s*(['"])(?!\2)"""
    ),
]


def has_words(message: str) -> bool:
    """False for pure layout patterns like '{name} · {until}' (nothing to translate)."""
    return any(ch.isalpha() for ch in re.sub(r"\{[^{}]*\}", "", message))


def messages(path: Path) -> dict[str, str]:
    data = json.loads(path.read_text(encoding="utf-8"))
    return {k: v for k, v in data.items() if not k.startswith("@")}


def check_arb() -> list[str]:
    errors = []
    bn_path, en_path = L10N / "app_bn.arb", L10N / "app_en.arb"
    bn_raw = json.loads(bn_path.read_text(encoding="utf-8"))
    bn, en = messages(bn_path), messages(en_path)
    errors += [f"missing in app_en.arb: {k}" for k in sorted(bn.keys() - en.keys())]
    errors += [f"missing in app_bn.arb: {k}" for k in sorted(en.keys() - bn.keys())]
    for key in sorted(bn.keys() & en.keys()):
        if not bn[key].strip() or not en[key].strip():
            errors.append(f"empty message: {key}")
        if set(PLACEHOLDER.findall(bn[key])) != set(PLACEHOLDER.findall(en[key])):
            errors.append(f"placeholders differ for {key}: {bn[key]!r} vs {en[key]!r}")
        if not bn_raw.get(f"@{key}", {}).get("description"):
            errors.append(f"no @description in app_bn.arb: {key}")
        if bn[key] == en[key] and key not in SAME_IN_BOTH and has_words(bn[key]):
            errors.append(f"English copy identical to Bengali (untranslated?): {key}")
    return errors


def check_literals() -> list[str]:
    errors = []
    for path in sorted((APP / "lib").rglob("*.dart")):
        if L10N in path.parents or path.name.endswith(".g.dart"):
            continue
        for n, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            if "l10n-ok" in line or line.lstrip().startswith("//"):
                continue
            if any(p.search(line) for p in LITERAL_PATTERNS):
                errors.append(f"{path.relative_to(ROOT)}:{n}: hard-coded UI string: {line.strip()}")
    return errors


def main() -> int:
    errors = check_arb() + check_literals()
    for e in errors:
        print(f"ERROR: {e}")
    print(f"l10n check: {len(errors)} error(s)")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
