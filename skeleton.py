import ipaddress
import json5

SKELETON_FILE = "skeleton.json"

def apply(hiddify_outbounds, tags):
    # Load skeleton (JSONC → json5)
    with open(SKELETON_FILE, "r", encoding="utf-8-sig") as f:
        skel = json5.load(f)

    # Determine the first outbound with an IP in the "server" field
    ip_outbound_tag = None
    for ob in hiddify_outbounds:
        server = ob.get("server")
        if server:
            try:
                ipaddress.ip_address(server)
                ip_outbound_tag = ob["tag"]
                break
            except ValueError:
                pass

    # If there is no IP outbound, fallback → first available
    if not ip_outbound_tag and hiddify_outbounds:
        ip_outbound_tag = hiddify_outbounds[0]["tag"]

    # List of all tags of available outbounds
    all_tags = [ob["tag"] for ob in hiddify_outbounds]

    def replace(obj):
        if isinstance(obj, str):
            if obj == "__OUTBOUND_TAGS__":
                return all_tags
            elif obj == "__IP_OUTBOUND__":
                return ip_outbound_tag
            elif obj == "__HIDDIFY_OUTBOUNDS__":
                return hiddify_outbounds
            else:
                return obj

        elif isinstance(obj, list):
            new_list = []
            for item in obj:
                if item == "__OUTBOUND_TAGS__":
                    new_list.extend(all_tags)
                elif item == "__HIDDIFY_OUTBOUNDS__":
                    new_list.extend(hiddify_outbounds)
                elif item == "__IP_OUTBOUND__":
                    if ip_outbound_tag:
                        new_list.append(ip_outbound_tag)
                else:
                    new_list.append(replace(item))
            return new_list

        elif isinstance(obj, dict):
            return {k: replace(v) for k, v in obj.items()}

        else:
            return obj

    return replace(skel)