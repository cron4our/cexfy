import requests

def fetch_config(domain: str, secret: str, user_uuid: str, query: str = "") -> dict:
    """
    Downloads the original full-singbox config from Hiddify
    query = "asn=unknown" или "asn=xyz&device=android"
    """
    url = f"https://{domain}/{secret}/{user_uuid}/singbox/"
    if query:
        url += f"?{query}"
    r = requests.get(url, timeout=10)
    r.raise_for_status()
    return r.json()

def extract_outbounds(config: dict):
    """
    Collects working outbounds
    """
    outbounds = []
    tags = []
    for ob in config.get("outbounds", []):
        if ob["type"] not in ("selector", "urltest", "direct", "bypass", "block", "dns"):
            outbounds.append(ob)
            tags.append(ob["tag"])
    return outbounds, tags


# Debugging code to test the function

# import json
# import io

# if __name__ == "__main__":
#     cfg = fetch_config("testtoken")
#     print("TYPE:", type(cfg))
#     print("FIRST 300 CHARS:", str(cfg)[:300])
