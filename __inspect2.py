from pathlib import Path

text = Path("skeleton.json").read_text(encoding="utf-8-sig")
print("lines", len(text.splitlines()))
