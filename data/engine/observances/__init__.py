"""Observance rule engine and YAML rules (spec §6.6, T-501).

``rules`` defines the rule schema and loads ``<id>.yaml`` files and the moment
definitions; ``engine`` evaluates rules against an ``Almanac`` of one tradition and
returns ``ObservanceRow``s, each with its tradition, a status and its windows.
"""

from .engine import Almanac, Day, EngineError, ObservanceRow, Window, evaluate
from .rules import Rule, RuleError, load_moments, load_rules, parse_rule

__all__ = [
    "Almanac",
    "Day",
    "EngineError",
    "ObservanceRow",
    "Rule",
    "RuleError",
    "Window",
    "evaluate",
    "load_moments",
    "load_rules",
    "parse_rule",
]
