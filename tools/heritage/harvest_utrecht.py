#!/usr/bin/env python3
"""يشتغل على جهازك (مفيش حد وقت). يفحص كل مخطوطات Utrecht المرقمنة (~25,700)
ويبني utrecht.json بالقبطي/اليوناني/الديموطيقي/السرياني/المصري المسيحي فقط.
التشغيل:  python harvest_utrecht.py
يحفظ تقدّمه كل 500، فلو وقف شغّله تاني يكمّل من حيث انتهى.
"""
import urllib.request, json, time, re, os
try:
    import truststore; truststore.inject_into_ssl()
except Exception:
    pass
UA = "AvaMakar-Heritage/1.0 (monastery archive; polite)"
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "utrecht.json")
KEEP = re.compile(r"copt|greek|grec|syriac|syri|demotic|egypt|hierogl|papyr|christ|gospel|evangel|psalm|psalter|\bbible|liturg|armenian|georgian|ethiop|ge.?ez|lectionar|homil", re.I)
DROP = re.compile(r"hebrew|hebreeuw|talmud|koran|qur|islam", re.I)

def get(u):
    for a in range(3):
        try:
            return urllib.request.urlopen(urllib.request.Request(u, headers={"User-Agent": UA}), timeout=40).read()
        except Exception:
            time.sleep(0.6 + a)
    return None

# 1) اجمع كل المعرّفات من الـsitemap
ids = []
for L in "0abcdefghijklmnopqrstuvwxyz":
    d = get(f"https://objects.library.uu.nl/sitemap.php?letter={L}")
    if d:
        ids += re.findall(rb"20\.500\.14918-([0-9]+)", d)
ids = sorted(set(x.decode() for x in ids))
print(f"إجمالي العناصر: {len(ids)}")

# 2) استكمال: اللي اتحفظ قبل كده
have = set(); out = []
if os.path.exists(OUT):
    try:
        out = json.load(open(OUT, encoding="utf-8"))["manuscripts"]
        have = set(x["shelfmark"] for x in out)
    except Exception:
        pass
# نحتاج نعرف اللي اتفحص خلاص (مش بس اللي اتحفظ) -> نخزّن مؤشر
done_file = OUT + ".done"
done = set()
if os.path.exists(done_file):
    done = set(open(done_file, encoding="utf-8").read().split())

for i, h in enumerate(ids, 1):
    if h in done:
        continue
    raw = get(f"https://objects.library.uu.nl/manifest/iiif/v3/{h}")
    done.add(h)
    if raw:
        try:
            m = json.loads(raw)
            lab = m.get("label", {})
            lab = ((lab.get("none") or lab.get("en") or ["?"])[0] if isinstance(lab, dict) else lab) or ""
            lab = str(lab)
            meta = " ".join(str((e.get("value", {}) or {}).get("none", [""])[0]) for e in m.get("metadata", []))
            blob = lab + " " + meta
            if KEEP.search(blob) and not DROP.search(blob) and h not in have:
                out.append({"library": "Universiteitsbibliotheek Utrecht", "collection": "Oriental/Egyptian",
                            "shelfmark": h, "title": lab, "pages": len(m.get("items", [])),
                            "manifest": f"https://objects.library.uu.nl/manifest/iiif/v3/{h}",
                            "tier": 1, "rights": "Utrecht University Library"})
                have.add(h)
        except Exception:
            pass
    if i % 500 == 0:
        json.dump({"source": "Utrecht UL — Coptic/Greek/Egyptian Christian mss", "manuscripts": out},
                  open(OUT, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
        open(done_file, "w", encoding="utf-8").write(" ".join(done))
        print(f"  {i}/{len(ids)} | محتفظ {len(out)}")
    time.sleep(0.05)

json.dump({"source": "Utrecht UL — Coptic/Greek/Egyptian Christian mss", "manuscripts": out},
          open(OUT, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
print(f"خلص: {len(out)} عنصر في النطاق. الملف: {OUT}")
