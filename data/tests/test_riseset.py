"""T-206: sunrise/sunset/moonrise/moonset vs an independent implementation.

The places below are test inputs only (approximate public coordinates); the app's city
list and its coordinate source are Q13.
"""

from datetime import UTC, date, datetime

import astronomy
import pytest

from engine.riseset import IST_OFFSET, SunriseDefinition, city_days, day_events

PLACES = {
    "kolkata": (22.5726, 88.3639),
    "howrah": (22.5958, 88.2636),
    "siliguri": (26.7271, 88.3953),
    "darjeeling": (27.0410, 88.2663),
    "durgapur": (23.5204, 87.3119),
    "asansol": (23.6739, 86.9524),
    "bardhaman": (23.2324, 87.8615),
    "kharagpur": (22.3460, 87.2320),
    "delhi": (28.6139, 77.2090),
    "mumbai": (19.0760, 72.8777),
}
DAYS = [date(2026, m, 15) for m in range(1, 13)]


def ae_event(lat, lon, body, direction, day_start):
    t0 = datetime.fromtimestamp(day_start, UTC)
    t = astronomy.SearchRiseSet(
        body,
        astronomy.Observer(lat, lon, 0),
        direction,
        astronomy.Time.Make(t0.year, t0.month, t0.day, t0.hour, t0.minute, t0.second),
        1.0,
    )
    if t is None:
        return None
    unix = t.Utc().replace(tzinfo=UTC).timestamp()
    return unix if unix < day_start + 86_400 else None


def ist_midnight(d):
    return int(datetime(d.year, d.month, d.day, tzinfo=UTC).timestamp()) - IST_OFFSET


@pytest.mark.parametrize("name", PLACES)
def test_ten_places_twelve_days_within_a_minute(astro, name):
    lat, lon = PLACES[name]
    for d in DAYS:
        (row,) = city_days(astro, lat, lon, d, d)
        start = ist_midnight(d)
        sun = astronomy.Body.Sun
        rise = ae_event(lat, lon, sun, astronomy.Direction.Rise, start)
        sett = ae_event(lat, lon, sun, astronomy.Direction.Set, start)
        assert abs(row.sunrise - rise) <= 60, (name, d, "sunrise")
        assert abs(row.sunset - sett) <= 60, (name, d, "sunset")
        moon = astronomy.Body.Moon
        for ours, direction in (
            (row.moonrise, astronomy.Direction.Rise),
            (row.moonset, astronomy.Direction.Set),
        ):
            theirs = ae_event(lat, lon, moon, direction, start)
            if ours is None or theirs is None:
                # Both must agree that there is none, unless it is at the day's edge.
                edge = theirs if ours is None else ours
                assert edge is None or min(edge - start, start + 86_400 - edge) < 120
            else:
                assert abs(ours - theirs) <= 120, (name, d, direction)


def test_q3_flag_centre_rises_later_than_upper_limb(astro):
    lat, lon = PLACES["kolkata"]
    upper = city_days(astro, lat, lon, date(2026, 6, 1), date(2026, 6, 7))
    centre = city_days(
        astro, lat, lon, date(2026, 6, 1), date(2026, 6, 7), SunriseDefinition.CENTRE
    )
    for u, c in zip(upper, centre, strict=True):
        assert 40 < c.sunrise - u.sunrise < 150
        assert 40 < u.sunset - c.sunset < 150


def test_day_events_allow_a_missing_sun_event_and_city_days_refuses_it(astro):
    # London: sunset near 18:30 UTC (IST midnight) in spring, so some IST days hold none.
    lat, lon = 51.5074, -0.1278
    rows = day_events(astro, lat, lon, date(2026, 3, 20), date(2026, 4, 30))
    assert any(r.sunset is None for r in rows)
    assert all(r.sunrise is not None for r in rows)
    missing = next(r.date for r in rows if r.sunset is None)
    with pytest.raises(ValueError, match="no sunrise or sunset"):
        city_days(astro, lat, lon, missing, missing)
    kolkata = PLACES["kolkata"]
    d = date(2026, 6, 1)
    (e,) = day_events(astro, *kolkata, d, d)
    (c,) = city_days(astro, *kolkata, d, d)
    assert (e.sunrise, e.sunset, e.moonrise, e.moonset) == (
        c.sunrise,
        c.sunset,
        c.moonrise,
        c.moonset,
    )


def test_some_days_have_no_moonrise(astro):
    lat, lon = PLACES["kolkata"]
    rows = city_days(astro, lat, lon, date(2026, 1, 1), date(2026, 3, 31))
    assert any(r.moonrise is None for r in rows)
    assert any(r.moonset is None for r in rows)
    for r in rows:
        assert r.sunrise < r.sunset
        start = ist_midnight(r.date)
        assert start <= r.sunrise < start + 86_400
