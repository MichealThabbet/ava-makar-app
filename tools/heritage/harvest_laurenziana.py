#!/usr/bin/env python3
"""يشتغل على جهازك (جهازك بيعدّي Cloudflare). يحصد كل مخطوطات مكتبة لورنتسيانا
(Biblioteca Medicea Laurenziana, فلورنسا) عبر OAI-PMH، ويبني laurenziana.json
بالسرياني/القبطي/اليوناني/العربي المسيحي/الأرمني/الجورجي/الحبشي فقط (يستبعد الإسلامي).
التشغيل:  python harvest_laurenziana.py
"""
import urllib.request, urllib.parse, re, json, time, os
try:
    import truststore; truststore.inject_into_ssl()
except Exception:
    pass
UA = "Mozilla/5.0 (AvaMakar-Heritage; monastery archive; polite)"
BASE = "https://cdm21059.contentdm.oclc.org/oai/oai.php"
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "laurenziana.json")
KEEP = re.compile(r"syriac|syriaco|siriac|copt|graec|greco|greek|grec|armen|georgian|giorgian|aethiop|ethiop|ge.?ez|arab", re.I)
# نستبعد الإسلامي والعبري
DROP = re.compile(r"coran|qur|islam|alcoran|ebraico|hebrew|hebraic|talmud", re.I)

def fetch(url):
    for a in range(4):
        try:
            return urllib.request.urlopen(urllib.request.Request(url, headers={"User-Agent": UA}), timeout=60).read().decode("utf-8", "ignore")
        except Exception:
            time.sleep(1.5 + a)
    return ""

out = []
token = None
page = 0
while True:
    if token:
        url = f"{BASE}?verb=ListRecords&resumptionToken={urllib.parse.quote(token)}"
    else:
        url = f"{BASE}?verb=ListRecords&metadataPrefix=oai_qdc&set=plutei"
    xml = fetch(url)
    if not xml:
        break
    for rec in re.findall(r"<record>.*?</record>", xml, re.S):
        mid = re.search(r"plutei/(\d+)", rec)
        title = re.search(r"<dc:title>(.*?)</dc:title>", rec, re.S)
        if not mid:
            continue
        t = (title.group(1) if title else "").strip()
        if KEEP.search(t) and not DROP.search(t):
            out.append({"library": "Biblioteca Medicea Laurenziana, Florence", "collection": "Oriental Christian",
                        "shelfmark": "plutei_" + mid.group(1), "title": re.sub(r"\s+", " ", t)[:140],
                        "manifest": f"https://cdm21059.contentdm.oclc.org/iiif/plutei:{mid.group(1)}/manifest.json",
                        "pages": 0, "tier": 1, "rights": "CC BY-NC-SA"})
    page += 1
    print(f"  صفحة {page} | محتفظ {len(out)}")
    m = re.search(r"<resumptionToken[^>]*>([^<]+)</resumptionToken>", xml)
    token = m.group(1).strip() if m and m.group(1).strip() else None
    json.dump({"source": "Biblioteca Medicea Laurenziana via OAI-PMH — Oriental Christian mss", "manuscripts": out},
              open(OUT, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    if not token:
        break
    time.sleep(0.5)

print(f"خلص: {len(out)} مخطوطة شرقية مسيحية. الملف: {OUT}")
