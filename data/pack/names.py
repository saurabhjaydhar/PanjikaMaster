"""Display names and glossary entries from `content/names.toml` (spec §13.1)."""

import tomllib
import unicodedata
from pathlib import Path

NAMES_PATH = Path(__file__).resolve().parents[1] / "content" / "names.toml"


def translit(entry: dict) -> str:
    """The entry's `translit`, else a lower-case ASCII form of its English name."""
    if "translit" in entry:
        return entry["translit"]
    ascii_form = unicodedata.normalize("NFKD", entry["en"]).encode("ascii", "ignore").decode()
    return ascii_form.lower()


def load_document() -> dict:
    return tomllib.loads(NAMES_PATH.read_text(encoding="utf-8"))


def load_names() -> dict[str, list[dict]]:
    """Entries by kind; list order is the 0-based index."""
    return {k: v for k, v in load_document().items() if isinstance(v, list)}


def status() -> str:
    """'draft' until the reviewer signs off (Q5, Q14)."""
    return load_document()["status"]


def rows(pack_id: str) -> list[tuple]:
    """`names` table rows for [pack_id]."""
    return [
        (kind, i, e["bn"], e["en"], translit(e), e.get("gloss_bn"), e.get("gloss_en"), pack_id)
        for kind, entries in load_names().items()
        for i, e in enumerate(entries)
    ]
