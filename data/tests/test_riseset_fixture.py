"""T-315: the shared rise/set fixture covers what §6.5.5 promises, and the pipeline's
events in it agree with an independent implementation (Astronomy Engine, §6.7).

Reads app/test/fixtures/riseset.json; that it is up to date is checked by
`scripts/gen_riseset_fixture.py --check` in ci-data.
"""

import json
from datetime import date
from pathlib import Path

import astronomy
import pytest
from test_riseset import ae_event, ist_midnight

from validate.riseset_fixture import DAYS, PLACES

FIXTURE = Path(__file__).resolve().parents[2] / "app" / "test" / "fixtures" / "riseset.json"


@pytest.fixture(scope="module")
def fixture():
    return json.loads(FIXTURE.read_text(encoding="utf-8"))


def test_covers_places_worldwide_and_days_2020_to_2043(fixture):
    places = fixture["places"]
    assert len(places) >= 40
    lats = [p["lat"] for p in places.values()]
    lons = [p["lon"] for p in places.values()]
    assert max(lats) == 60 and min(lats) == -60  # the app's limit (FR-LOC-07)
    assert min(lons) < -170 and max(lons) > 170  # both sides of the date line
    assert {"kolkata", "nainital", "london", "new_york"} <= set(places)
    assert fixture["days"] == [d.isoformat() for d in DAYS]
    assert len(set(d[:4] for d in fixture["days"])) == 24  # one per year
    assert len({d[5:7] for d in fixture["days"]}) == 12  # every month


def test_positions_cover_each_day_and_the_next(fixture):
    rows = fixture["body_positions"]
    for d in DAYS:
        for day in (d, date.fromordinal(d.toordinal() + 1)):
            row = rows[day.isoformat()]
            assert row["start_utc"] == ist_midnight(day)
            assert len(row["sun_ra"]) == 4 and len(row["moon_ra"]) == 7


def test_events_lie_inside_their_ist_day(fixture):
    for place, days in fixture["expected"].items():
        for day, events in days.items():
            start = ist_midnight(date.fromisoformat(day))
            for e in events:
                assert e is None or start <= e < start + 86_400, (place, day)


@pytest.mark.parametrize("name", PLACES)
def test_pipeline_matches_astronomy_engine(fixture, name):
    lat, lon = PLACES[name]
    kinds = (
        (astronomy.Body.Sun, astronomy.Direction.Rise, 60),
        (astronomy.Body.Sun, astronomy.Direction.Set, 60),
        (astronomy.Body.Moon, astronomy.Direction.Rise, 120),
        (astronomy.Body.Moon, astronomy.Direction.Set, 120),
    )
    for day, events in fixture["expected"][name].items():
        start = ist_midnight(date.fromisoformat(day))
        for ours, (body, direction, tolerance) in zip(events, kinds, strict=True):
            theirs = ae_event(lat, lon, body, direction, start)
            if ours is None or theirs is None:
                # Both must say "none", unless the event sits at the day's edge.
                edge = theirs if ours is None else ours
                assert edge is None or min(edge - start, start + 86_400 - edge) < 180, (
                    name,
                    day,
                    direction,
                )
            else:
                assert abs(ours - theirs) <= tolerance, (name, day, body, direction)
