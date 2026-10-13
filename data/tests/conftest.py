import sys
from pathlib import Path

# Make `engine`, `validate` and `pack` importable without installing the project.
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
