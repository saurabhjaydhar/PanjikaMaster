# Data pipeline

Python pipeline that computes, validates, packs and signs panjika data (PRD §6.4). Independent of the Flutter app; the two share only the pack files and `pack/schema.sql`.

```sh
cd data
uv sync            # creates .venv with Python 3.12 and dev tools
uv run ruff check .
uv run pytest
uv run python -m pack.sample --out dist/sample   # SAMPLE fixture packs for app development
# Correction (§18): prove a rebuilt observances pack changes only the named observances
uv run python -m pack.correction --base <vN>.sqlite --new <vN+1>.sqlite --observance <id> --reason "…"
```

Layout: `ephem/` ephemeris download + checksum · `engine/` astronomy, panchanga, Bengali date, observances · `reference/` human-entered validation values · `validate/` comparison reports · `pack/` SQLite pack builder and signing · `tests/`.
