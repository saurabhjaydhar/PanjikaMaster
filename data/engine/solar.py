"""Sankranti: the moments the Sun's nirayana longitude crosses a multiple of 30°
(spec §6.5.6, T-205). Index 0 = entry into Mesha, which begins বৈশাখ; 11 = Meena → চৈত্র.

Each span runs from one sankranti to the next. Which civil day a Bengali month starts
on is a separate rule (the Bengal midnight rule, bengali.py, Q4).
"""

from engine.astro import Astro
from engine.panchanga import Span, search_in_chunks


def sankrantis(astro: Astro, start: int, end: int) -> list[Span]:
    """The Sun's sign spans overlapping [start, end), in order."""
    return search_in_chunks("sankranti", astro, start, end)
