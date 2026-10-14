"""Access to the pack schema (spec §15.1) for the builder and tests."""

import sqlite3
from pathlib import Path

SCHEMA_PATH = Path(__file__).with_name("schema.sql")
SCHEMA_VERSION = 2  # 2: body_positions (T-314)

# Tables a pack may contain, in dependency order (parents before children).
PACK_TABLES = (
    "packs",
    "transitions",
    "lunar_months",
    "cities",
    "city_days",
    "bengali_dates",
    "body_positions",
    "names",
    "observances",
    "observance_dates",
    "observance_windows",
    "period_rules",
)


def create(conn: sqlite3.Connection) -> None:
    """Create every pack table on an empty database and enable foreign keys."""
    conn.execute("PRAGMA foreign_keys = ON")
    conn.executescript(SCHEMA_PATH.read_text(encoding="utf-8"))


def connect(path: str | Path = ":memory:") -> sqlite3.Connection:
    """Open a database with the schema applied."""
    conn = sqlite3.connect(path)
    create(conn)
    return conn


def columns(conn: sqlite3.Connection, table: str) -> list[str]:
    return [row[1] for row in conn.execute(f"PRAGMA table_info({table})")]
