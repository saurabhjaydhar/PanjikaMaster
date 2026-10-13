"""T-603: correction packs change only the observances they declare.

Inputs are the synthetic sample pack and copies of it edited here; none of this is
calendar data.
"""

import json
import shutil
import sqlite3

import pytest

from pack import correction, sample
from pack.correction import CorrectionRejected


@pytest.fixture
def packs(tmp_path):
    global_, _, observances = sample.build(tmp_path / "src")
    base = tmp_path / "base.sqlite"
    new = tmp_path / "new.sqlite"
    shutil.copy(observances, base)
    shutil.copy(observances, new)
    run(new, "UPDATE packs SET version = version + 1")
    return base, new, global_


def run(path, sql, *args):
    conn = sqlite3.connect(path)
    with conn:
        conn.execute(sql, args)
    conn.close()


def move_a_day(path, oid):
    for table in ("observance_dates", "observance_windows"):
        run(path, f"UPDATE {table} SET date = date(date, '+1 day') WHERE observance_id = ?", oid)


def summary(path):
    conn = sqlite3.connect(path)
    value = conn.execute("SELECT validation_summary FROM packs").fetchone()[0]
    conn.close()
    return json.loads(value)


def test_a_declared_date_change_is_recorded(packs):
    base, new, _ = packs
    run(new, "UPDATE packs SET validation_summary = ?", json.dumps({"status": "computed"}))
    move_a_day(new, "kali_puja")
    record = correction.correct(base, new, ["kali_puja"], "  rule fix after a report  ")
    assert record == {
        "of_version": 1,
        "observances": ["kali_puja"],
        "reason": "rule fix after a report",
    }
    meta = summary(new)
    assert meta["correction"] == record
    assert meta["status"] == "computed", "the rest of the summary is kept"


def test_an_undeclared_change_is_refused(packs):
    base, new, _ = packs
    move_a_day(new, "kali_puja")
    move_a_day(new, "lakshmi_puja")
    with pytest.raises(CorrectionRejected, match="not declared: lakshmi_puja"):
        correction.correct(base, new, ["kali_puja"], "fix")


def test_a_declared_observance_must_have_changed_dates(packs):
    base, new, _ = packs
    with pytest.raises(CorrectionRejected, match="did not change: kali_puja"):
        correction.correct(base, new, ["kali_puja"], "fix")
    # A description fix alone is not a date correction.
    run(new, "UPDATE observances SET description_en = 'x' WHERE id = 'kali_puja'")
    with pytest.raises(CorrectionRejected, match="did not change: kali_puja"):
        correction.correct(base, new, ["kali_puja"], "fix")


def test_other_tables_must_be_identical(packs):
    base, new, _ = packs
    move_a_day(new, "kali_puja")
    run(
        new,
        "INSERT INTO names (kind, idx, name_bn, name_en, translit, pack_id)"
        " SELECT 'tradition', 99, 'x', 'x', 'x', id FROM packs",
    )
    with pytest.raises(CorrectionRejected, match="names: 1 rows differ"):
        correction.correct(base, new, ["kali_puja"], "fix")


def test_version_kind_and_reason(packs, tmp_path):
    base, new, global_ = packs
    move_a_day(new, "kali_puja")
    with pytest.raises(CorrectionRejected, match="needs a reason"):
        correction.correct(base, new, ["kali_puja"], " ")
    run(new, "UPDATE packs SET version = 3")
    with pytest.raises(CorrectionRejected, match="must follow 1"):
        correction.correct(base, new, ["kali_puja"], "fix")
    with pytest.raises(CorrectionRejected, match="only observances packs"):
        correction.correct(base, global_, ["kali_puja"], "fix")


def test_cli(packs, capsys):
    base, new, _ = packs
    move_a_day(new, "kali_puja")
    args = ["--base", str(base), "--new", str(new), "--reason", "fix"]
    assert correction.main([*args, "--observance", "lakshmi_puja"]) == 1
    assert "REJECTED" in capsys.readouterr().err
    assert correction.main([*args, "--observance", "kali_puja"]) == 0
    assert "correction of v1: kali_puja" in capsys.readouterr().out
