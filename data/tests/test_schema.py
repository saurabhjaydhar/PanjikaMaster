"""T-102: the pack schema (spec §15.1) creates cleanly and enforces its rules."""

import sqlite3

import pytest

from pack import schema

PACK = "test-pack"


@pytest.fixture
def db() -> sqlite3.Connection:
    conn = schema.connect()
    conn.execute(
        "INSERT INTO packs (id, tradition, kind, is_sample, covers_from, covers_to, version,"
        " generated_at, engine_version) VALUES (?, 'drik_bishuddha', 'global', 1,"
        " '2026-01-01', '2026-12-31', 1, '2026-10-12T00:00:00Z', 'test')",
        (PACK,),
    )
    return conn


def tables(conn: sqlite3.Connection) -> set[str]:
    rows = conn.execute("SELECT name FROM sqlite_master WHERE type = 'table'")
    return {r[0] for r in rows}


def test_creates_exactly_the_pack_tables(db):
    assert tables(db) == set(schema.PACK_TABLES)


def test_schema_version(db):
    assert db.execute("PRAGMA user_version").fetchone()[0] == schema.SCHEMA_VERSION


def test_every_table_except_packs_has_a_required_pack_id(db):
    for table in schema.PACK_TABLES[1:]:
        info = {r[1]: r for r in db.execute(f"PRAGMA table_info({table})")}
        assert "pack_id" in info, table
        assert info["pack_id"][3] == 1, f"{table}.pack_id must be NOT NULL"
        fks = {(r[3], r[2]) for r in db.execute(f"PRAGMA foreign_key_list({table})")}
        assert ("pack_id", "packs") in fks, f"{table}.pack_id must reference packs"


def test_tables_are_strict(db):
    for table in schema.PACK_TABLES:
        sql = db.execute("SELECT sql FROM sqlite_master WHERE name = ?", (table,)).fetchone()[0]
        assert sql.rstrip().endswith("STRICT"), table


def test_foreign_keys_enforced(db):
    with pytest.raises(sqlite3.IntegrityError):
        db.execute(
            "INSERT INTO bengali_dates VALUES ('drik_bishuddha', '2026-04-15', 1, 0, 1433,"
            " 'no-such-pack')"
        )


def insert_transition(db, kind, idx, start=0, end=100):
    db.execute(
        "INSERT INTO transitions (pack_id, tradition, kind, idx, starts_utc, ends_utc)"
        " VALUES (?, 'drik_bishuddha', ?, ?, ?, ?)",
        (PACK, kind, idx, start, end),
    )


@pytest.mark.parametrize(
    ("kind", "max_idx"),
    [("tithi", 29), ("nakshatra", 26), ("yoga", 26), ("karana", 59), ("sankranti", 11)],
)
def test_transition_index_ranges(db, kind, max_idx):
    insert_transition(db, kind, 0)
    insert_transition(db, kind, max_idx)
    with pytest.raises(sqlite3.IntegrityError):
        insert_transition(db, kind, max_idx + 1)
    with pytest.raises(sqlite3.IntegrityError):
        insert_transition(db, kind, -1)


def test_transition_must_end_after_it_starts(db):
    with pytest.raises(sqlite3.IntegrityError):
        insert_transition(db, "tithi", 0, start=100, end=100)


def test_unknown_transition_kind_rejected(db):
    with pytest.raises(sqlite3.IntegrityError):
        insert_transition(db, "rashi", 0)


def insert_name(db, name_bn, name_en, gloss_bn=None, gloss_en=None):
    db.execute(
        "INSERT INTO names (kind, idx, name_bn, name_en, translit, gloss_bn, gloss_en, pack_id)"
        " VALUES ('tithi', 0, ?, ?, 'x', ?, ?, ?)",
        (name_bn, name_en, gloss_bn, gloss_en, PACK),
    )


@pytest.mark.parametrize(("name_bn", "name_en"), [("", "Pratipada"), ("প্রতিপদ", ""), (None, "x")])
def test_names_need_both_languages(db, name_bn, name_en):
    with pytest.raises(sqlite3.IntegrityError):
        insert_name(db, name_bn, name_en)


def test_glosses_come_in_pairs(db):
    with pytest.raises(sqlite3.IntegrityError):
        insert_name(db, "প্রতিপদ", "Pratipada", gloss_bn="শুধু বাংলা")


def insert_observance(db, description_en="An English description."):
    db.execute(
        "INSERT INTO observances VALUES ('kali_puja', 'কালীপূজা', 'Kali Puja', 'puja', 1,"
        " 'বাংলা বিবরণ।', ?, ?)",
        (description_en, PACK),
    )


def test_observance_needs_both_descriptions(db):
    with pytest.raises(sqlite3.IntegrityError):
        insert_observance(db, description_en="")


def insert_observance_date(db, status, reviewed_by=None, reviewed_on=None):
    db.execute(
        "INSERT INTO observance_dates (observance_id, tradition, date, status, reviewed_by,"
        " reviewed_on, pack_id) VALUES ('kali_puja', 'drik_bishuddha', '2026-01-01', ?, ?, ?, ?)",
        (status, reviewed_by, reviewed_on, PACK),
    )


@pytest.mark.parametrize("status", ["stale", "verified", ""])
def test_unknown_status_rejected(db, status):
    insert_observance(db)
    with pytest.raises(sqlite3.IntegrityError):
        insert_observance_date(db, status)


def test_expert_reviewed_requires_reviewer_and_date(db):
    insert_observance(db)
    with pytest.raises(sqlite3.IntegrityError):
        insert_observance_date(db, "expert_reviewed")
    insert_observance_date(db, "expert_reviewed", reviewed_by="AB", reviewed_on="2026-03-20")


def test_window_kind_is_required_and_unique(db):
    insert_observance(db)
    insert_observance_date(db, "sample")
    row = ("kali_puja", "drik_bishuddha", "2026-01-01")
    sql = "INSERT INTO observance_windows VALUES (?, ?, ?, ?, 0, 60, ?)"
    with pytest.raises(sqlite3.IntegrityError):
        db.execute(sql, (*row, None, PACK))
    db.execute(sql, (*row, "nishita", PACK))
    with pytest.raises(sqlite3.IntegrityError):
        db.execute(sql, (*row, "nishita", PACK))


def test_window_needs_its_observance_date(db):
    insert_observance(db)
    with pytest.raises(sqlite3.IntegrityError):
        db.execute(
            "INSERT INTO observance_windows VALUES ('kali_puja', 'drik_bishuddha', '2026-01-01',"
            " 'nishita', 0, 60, ?)",
            (PACK,),
        )


def test_period_rule_part_within_divisions(db):
    sql = "INSERT INTO period_rules VALUES ('drik_bishuddha', 0, 'ashubh', 1, 'day', 8, ?, 0, ?)"
    db.execute(sql, (2, PACK))
    with pytest.raises(sqlite3.IntegrityError):
        db.execute(sql.replace("1, 'day'", "2, 'day'"), (9, PACK))


def test_strict_types(db):
    with pytest.raises(sqlite3.IntegrityError):
        insert_transition(db, "tithi", "seven")
