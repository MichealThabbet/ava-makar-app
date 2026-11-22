#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""يحصد مخطوطات لورنتسيانا عبر OAI-PMH بمتصفح حقيقي (Playwright) يعدّي Cloudflare.
تثبيت مرة واحدة:
    pip install playwright
    playwright install chromium
التشغيل:
    python harvest_laurenziana_browser.py
بيفتح نافذة Chrome (سيبها مفتوحة)، ويبني laurenziana.json.
"""
import re, json, os, sys, time, urllib.parse
try:
    from playwright.sync_api import sync_playwright
except ImportError:
    print("محتاج تثبّت الأول:\n  pip install playwright\n  playwright install chromium")
    input("Enter للخروج..."); sys.exit(1)

BASE = "https://cdm21059.contentdm.oclc.org/oai/oai.php"
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "laurenziana.json")
KEEP = re.compile(r"syriac|syriaco|siriac|copt|graec|greco|greek|grec|armen|georgian|giorgian|aethiop|ethiop|ge.?ez|arab", re.I)
DROP = re.compile(r"coran|qur|islam|alcoran|ebraico|hebrew|hebraic|talmud", re.I)

out = []

with sync_playwright() as pw:
    browser = pw.chromium.launch(headless=False)   # نافذة حقيقية تعدّي Cloudflare
    page = browser.new_page()

    def get_xml(url):
        page.goto(url, wait_until="domcontentloaded", timeout=90000)
        # لو ظهر تحدّي Cloudflare، استنى يعدّي
        for _ in range(20):
            txt = page.content()
            if "<record" in txt or "<OAI-PMH" in txt or "noRecordsMatch" in txt:
                return txt
            time.sleep(1.5)
        return page.content()

    xml = get_xml(f"{BASE}?verb=ListRecords&metadataPrefix=oai_qdc&set=plutei")
    pageno = 0
    while True:
        # الصفحة بتبقى XML داخل HTML أحياناً؛ نطلّع السجلات بالريجيكس
        recs = re.findall(r"&lt;record&gt;.*?&lt;/record&gt;|<record>.*?</record>", xml, re.S)
        if not recs:
            recs = re.findall(r"<record.*?</record>", xml, re.S)
        for rec in recs:
            r = rec.replace("&lt;", "<").replace("&gt;", ">").replace("&amp;", "&")
            mid = re.search(r"plutei/(\d+)", r)
            title = re.search(r"<dc:title>(.*?)</dc:title>", r, re.S)
            if not mid:
                continue
            t = (title.group(1) if title else "").strip()
            if KEEP.search(t) and not DROP.search(t):
                out.append({"library": "Biblioteca Medicea Laurenziana, Florence", "collection": "Oriental Christian",
                            "shelfmark": "plutei_" + mid.group(1), "title": re.sub(r"\s+", " ", t)[:140],
                            "manifest": f"https://cdm21059.contentdm.oclc.org/iiif/plutei:{mid.group(1)}/manifest.json",
                            "pages": 0, "tier": 1, "rights": "CC BY-NC-SA"})
        pageno += 1
        print(f"  صفحة {pageno} | محتفظ {len(out)}")
        json.dump({"source": "Laurenziana via OAI (browser)", "manuscripts": out}, open(OUT, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
        tok = re.search(r"(?:&lt;|<)resumptionToken[^&<]*(?:&gt;|>)([^&<]+)(?:&lt;|<)", xml)
        if not tok or not tok.group(1).strip():
            break
        xml = get_xml(f"{BASE}?verb=ListRecords&resumptionToken={urllib.parse.quote(tok.group(1).strip())}")

    browser.close()

print(f"خلص: {len(out)} مخطوطة شرقية مسيحية. الملف: {OUT}")
input("Enter للخروج...")
