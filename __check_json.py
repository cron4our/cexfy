import json5
from pathlib import Path

path = Path("skeleton_zz11.json")
try:
    json5.loads(path.read_text(encoding="utf-8-sig"))
except Exception as exc:  # pragma: no cover - diagnostic helper
    print(type(exc).__name__, exc)
else:
    print("parsed ok")
