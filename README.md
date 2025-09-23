# cexfy

`cexfy` is a tiny tool that seamlessly **extends Hiddify’s limited full singbox config**.
Instead of serving the stock full singbox config via`/singbox/?asn=unknown#<user>` endpoint in HiddifyPanel, it injects your own rules and structure defined in `skeleton.json`.

---

## ✨ Key idea

- HiddifyPanel provides a very basic "full singbox" config. 
- `cexfy` extracts all **actual proxy outbounds**.
- These outbounds are injected into your template (`skeleton.json`).  
- Client apps (v2rayN, sing-box, etc) receive the final enriched **full singbox config** through the same full singbox link provided in HiddifyPanel.

---
