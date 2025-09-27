from pathlib import Path
from typing import Optional, Union

import hiddify
import skeleton


def build_config(
    domain: str,
    secret: str,
    user_uuid: str,
    query: str = "",
    skeleton_path: Optional[Union[str, Path]] = None,
) -> dict:
    parent = hiddify.fetch_config(domain, secret, user_uuid, query)
    outbounds, tags = hiddify.extract_outbounds(parent)
    result = skeleton.apply(outbounds, tags, skeleton_path)
    return result


# Debugging code to test the function

# if __name__ == "__main__":
#     result = build_config("testtoken")
#     print("TYPE:", type(result))
#     # Print the first 300 characters to avoid flooding
#     import json
#     print("FIRST 300 CHARS:", json.dumps(result, ensure_ascii=False)[:300])

