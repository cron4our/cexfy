import json
import os
import pathlib

from builder import build_config

if __name__ == "__main__":
    domain = os.environ.get("CEXFY_DOMAIN", "<domain>")
    secret = os.environ.get("CEXFY_SECRET", "<secret>")
    user_uuid = os.environ.get("CEXFY_UUID", "<user-uuid>")
    skeleton_path = os.environ.get("CEXFY_TEMPLATE", "skeleton.json")

    result = build_config(domain, secret, user_uuid, skeleton_path=skeleton_path)

    out_path = pathlib.Path(__file__).with_name("result.json")
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(result, f, indent=2, ensure_ascii=False)

    print(f"[DEBUG] Final config saved to {out_path}")

