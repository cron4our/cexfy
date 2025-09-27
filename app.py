import os
import json

from flask import Flask, Response, abort, request

from builder import build_config

# Load environment variables from .env if available
try:
    from dotenv import load_dotenv

    load_dotenv()
except ImportError:
    pass  # python-dotenv not installed, skip

# Read domain from env
DOMAIN = os.environ.get("CEXFY_DOMAIN")
if not DOMAIN:
    raise RuntimeError("Environment variable CEXFY_DOMAIN is not set!")

# Map URL prefixes to template files. Add new entries to expose more endpoints.
TEMPLATE_MAP = {
    "zz": "skeleton.json",
    "zz11": "skeleton_zz11.json",
}

app = Flask(__name__)
app.config["JSON_SORT_KEYS"] = False


@app.route("/<template>/<secret>/<uuid:user_uuid>/singbox/")
def custom_full(template, secret, user_uuid):
    skeleton_path = TEMPLATE_MAP.get(template)
    if skeleton_path is None:
        abort(404, description=f"Unknown template '{template}'")

    try:
        query = request.query_string.decode()  # The whole ?asn=...
        result = build_config(
            DOMAIN,
            secret,
            str(user_uuid),
            query,
            skeleton_path=skeleton_path,
        )

        # Return unsorted JSON
        return Response(
            json.dumps(result, ensure_ascii=False, indent=2, separators=(",", ":")),
            mimetype="application/json",
        )
    except FileNotFoundError as exc:
        abort(404, description=str(exc))
    except Exception as exc:  # pragma: no cover - safety net for runtime issues
        return {"error": str(exc)}, 500


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=9100)
