#!/usr/bin/env python3
"""يشتغل على جهازك. يحصد كل قصاصات Fragmentarium من الـ289 مؤسسة ويبني fragmentarium.json.
التشغيل:  python harvest_fragmentarium.py
يستكمل لو وقف (يتخطّى المؤسسات اللي اتحصدت).
"""
import urllib.request, json, time, os
try:
    import truststore; truststore.inject_into_ssl()
except Exception:
    pass
UA = "AvaMakar-Heritage/1.0 (monastery archive; polite)"
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "fragmentarium.json")

def get(u):
    for a in range(4):
        try:
            return json.load(urllib.request.urlopen(urllib.request.Request(u, headers={"User-Agent": UA}), timeout=50))
        except Exception:
            time.sleep(1.0 + a * 1.5)
    return None

top = get("https://fragmentarium.ms/metadata/iiif/collection.json")
cols = top.get("collections", []) if top else []
print(f"مؤسسات: {len(cols)}")

out = []; have = set()
if os.path.exists(OUT):
    try:
        out = json.load(open(OUT, encoding="utf-8"))["manuscripts"]
        have = set(x["collection"] for x in out)
    except Exception:
        pass

for i, c in enumerate(cols, 1):
    inst = str(c.get("label", ""))
    if inst in have:
        continue
    cd = get(c.get("@id"))
    if cd is None:
        continue
    for m in cd.get("manifests", []):
        out.append({"library": "Fragmentarium — " + inst, "collection": inst,
                    "shelfmark": (m.get("@id", "").split("/iiif/")[-1].split("/")[0]) or m.get("@id", ""),
                    "title": str(m.get("label", "")), "manifest": m.get("@id"), "pages": 0,
                    "tier": 2, "rights": "Fragmentarium (CC)", "note": "قصاصة من " + inst})
    have.add(inst)
    if i % 20 == 0:
        json.dump({"source": "Fragmentarium full", "manuscripts": out}, open(OUT, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
        print(f"  {i}/{len(cols)} مؤسسة | {len(out)} قصاصة")
    time.sleep(0.3)

json.dump({"source": "Fragmentarium full", "manuscripts": out}, open(OUT, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
print(f"خلص: {len(out)} قصاصة من {len(set(x['collection'] for x in out))} مؤسسة. الملف: {OUT}")
