"""Panjika computation engine (PRD §6.4–6.6).

Layers are kept in separate modules (PRD §5.1): astronomy, panchanga elements,
Bengali civil date and observance rules. Nothing here may contain hand-typed
calendar data; reference values live in ``data/reference/`` and are entered by
the human.
"""

# Recorded in every pack's `engine_version` (spec §6.4 step 1).
__version__ = "0.2.0"
