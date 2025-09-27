import os, json
from flask import Flask, jsonify, request, Response
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
    raise RuntimeError("❌ Environment variable CEXFY_DOMAIN is not set!")

app = Flask(__name__)
app.config["JSON_SORT_KEYS"] = False

@app.route("/zz/<secret>/<uuid:user_uuid>/singbox/")
def custom_full(secret, user_uuid):
    try:
        query = request.query_string.decode()  # The whole ?asn=...
        result = build_config(DOMAIN, secret, str(user_uuid), query)

        # Return unsorted JSON
        return Response(
            json.dumps(result, ensure_ascii=False, indent=2, separators=(",", ":")),
            mimetype="application/json"
        )
    except Exception as e:
        return {"error": str(e)}, 500

if __name__ == "__main__":
    app.run(host="127.0.0.1", port=9100)
