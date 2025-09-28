from pathlib import Path

text = Path("skeleton_zz11.json").read_text(encoding="utf-8-sig")
lines = text.splitlines()
print("lines", len(lines))
for idx in (360, 368, 369, 370):
    if idx <= len(lines):
        print(f"{idx}: {lines[idx-1]}")
