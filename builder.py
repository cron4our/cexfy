import hiddify
import skeleton

def build_config(domain: str, secret: str, user_uuid: str) -> dict:
    parent = hiddify.fetch_config(domain, secret, user_uuid)
    outbounds, tags = hiddify.extract_outbounds(parent)
    result = skeleton.apply(outbounds, tags)
    return result

# Debugging code to test the function

# if __name__ == "__main__":
#     result = build_config("testtoken")
#     print("TYPE:", type(result))
#     # Print the first 300 characters to avoid flooding
#     import json
#     print("FIRST 300 CHARS:", json.dumps(result, ensure_ascii=False)[:300])