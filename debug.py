import json
import pathlib
from builder import build_config

if __name__ == "__main__":
    # ⚠️ If you have multiple users, specify the actual token
    token = "<token>"

    # Build the config using the same process as Flask
    result = build_config(token)

    # Save the result next to the project
    out_path = pathlib.Path(__file__).with_name("result.json")
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(result, f, indent=2, ensure_ascii=False)

    print(f"[DEBUG] Final config saved to {out_path}")