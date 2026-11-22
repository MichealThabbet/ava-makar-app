#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""يحصد كل مخطوطات لورنتسيانا عبر OAI-PMH متخطّياً Cloudflare بمكتبة cloudscraper.
قبل التشغيل مرة واحدة:   pip install cloudscraper
التشغيل:                python harvest_laurenziana_cf.py
بيبني laurenziana.json (سرياني/قبطي/يوناني/عربي مسيحي/أرمني/جورجي/حبشي، بلا إسلامي/عبري).
"""
import re, json, time, os, sys, urllib.parse
try:
    import cloudscraper
except ImportError:
    print("محتاج تثبّت المكتبة الأول:  pip install cloudscraper")
    input("Enter للخروج..."); sys.exit(1)

BASE = "https://cdm21059.contentdm.oclc.org/oai/oai.php"
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "laurenziana.json")
KEEP = re.compile(r"syriac|syriaco|siriac|copt|graec|greco|greek|grec|armen|georgian|giorgian|aethiop|ethiop|ge.?ez|arab", re.I)
DROP = re.compile(r"coran|qur|islam|alcoran|ebraico|hebrew|hebraic|talmud", re.I)

scraper = cloudscraper.create_scraper(browser={"browser": "chrome", "platform": "windows"})

def fetch(url):
    for a in range(4):
        try:
            r = scraper.get(url, timeout=60)
            if r.status_code == 200:
                return r.text
            print("  HTTP", r.status_code, "- بحاول تاني...")
        except Exception as e:
            print("  خطأ:", repr(e)[:80])
        time.sleep(2 + a * 2)
    return ""

out = []; token = None; page = 0
# اختبار أول
first = fetch(f"{BASE}?verb=ListRecords&metadataPrefix=oai_qdc&set=plutei")
if "<record>" not in first:
    print(">>> لسه Cloudflare بيحجب حتى بـcloudscraper. محتاجين متصفح حقيقي (قوللي).")
    print("    أول 300 حرف:", first[:300])
    input("Enter للخروج..."); sys.exit(1)

xml = first
while True:
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
    json.dump({"source": "Laurenziana via OAI (cloudscraper)", "manuscripts": out}, open(OUT, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    m = re.search(r"<resumptionToken[^>]*>([^<]+)</resumptionToken>", xml)
    token = m.group(1).strip() if m and m.group(1).strip() else None
    if not token:
        break
    time.sleep(0.5)
    xml = fetch(f"{BASE}?verb=ListRecords&resumptionToken={urllib.parse.quote(token)}")
    if not xml:
        break

print(f"خلص: {len(out)} مخطوطة شرقية مسيحية. الملف: {OUT}")
input("Enter للخروج...")
