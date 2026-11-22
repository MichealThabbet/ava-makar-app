#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""مرجان كله — الجديد + CORSAIR القديم + أي subdomain.
بيزحف (crawl) على كل نطاقات themorgan.org، يجمع روابط Zoomify لكل صورة،
وبعدين dezoomify-rs بيفكّها فل دقة.

التشغيل على جهازك (متصفح حقيقي):
    pip install playwright && playwright install chromium

    # يزحف على كل اللي تديهوله (حط أي صفحات بداية تعرفها):
    python harvest_morgan.py "https://www.themorgan.org/manuscripts" "http://corsair.themorgan.org"

    # أو صفحة واحدة بس:
    python harvest_morgan.py "https://www.themorgan.org/manuscript/<id>"

بيطلّع morgan_zoomify.txt (كل روابط الصور). بعدها:
    dezoomify-rs -l morgan_zoomify.txt D:\\claude\\morgan_out

ملاحظة: الزحف محدود بنطاقات themorgan.org بس، وبحد أقصى صفحات (عدّله تحت MAX).
"""
import re, sys, time, os, urllib.parse as up

HERE = os.path.dirname(os.path.abspath(__file__))
OUT  = os.path.join(HERE, "morgan_zoomify.txt")
MAX  = 20000          # أقصى عدد صفحات يزحف عليها (زوّده لو عايز)
DOMAIN_OK = re.compile(r"(^|\.)themorgan\.org$", re.I)

def host_ok(u):
    try: return bool(DOMAIN_OK.search(up.urlparse(u).hostname or ""))
    except Exception: return False

def find_zoomify(html):
    out = []
    for u in re.findall(r'https?://[^"\'\\s<>]+?(?:ImageProperties\.xml|/zoomify/[^"\'\\s<>]+|/TileGroup\d+/[^"\'\\s<>]+)', html):
        base = re.split(r'/TileGroup\d+/', u)[0].rstrip("/")
        ip = u if "ImageProperties.xml" in u else base + "/ImageProperties.xml"
        out.append(ip)
    return out

def links_in(html, cur):
    out = []
    for h in re.findall(r'href=["\']([^"\']+)', html):
        full = up.urljoin(cur, h)
        if host_ok(full) and full.split("#")[0] not in (cur,):
            out.append(full.split("#")[0])
    return out

def run(seeds):
    from playwright.sync_api import sync_playwright
    zoom, seen_pg, found = [], set(), set()
    queue = [s for s in seeds if host_ok(s)]
    with sync_playwright() as pw:
        b = pw.chromium.launch(headless=False); pg = b.new_page()
        while queue and len(seen_pg) < MAX:
            u = queue.pop(0)
            if u in seen_pg: continue
            seen_pg.add(u)
            try:
                pg.goto(u, wait_until="domcontentloaded", timeout=90000); time.sleep(1.0)
                html = pg.content()
            except Exception as e:
                print("  خطأ:", repr(e)[:50]); continue
            for z in find_zoomify(html):
                if z not in found:
                    found.add(z); zoom.append(z)
            # زوّد صفحات المخطوطات للطابور
            for l in links_in(html, u):
                if l not in seen_pg and re.search(r"manuscript|object|collection|record|coptic|detail|work", l, re.I):
                    queue.append(l)
            if len(seen_pg) % 10 == 0 or not queue:
                open(OUT, "w", encoding="utf-8").write("\n".join(zoom))
                print(f"  صفحات={len(seen_pg)}  طابور={len(queue)}  صور={len(zoom)}")
        b.close()
    open(OUT, "w", encoding="utf-8").write("\n".join(zoom))
    print(f"\nخلص. {len(zoom)} رابط صورة في {OUT}")
    print("دلوقتي:  dezoomify-rs -l morgan_zoomify.txt D:\\claude\\morgan_out")

# نقاط بداية افتراضية لو شغّلت السكربت من غير روابط — يزحف منهم لكل الموقع
DEFAULT_SEEDS = [
    "https://www.themorgan.org/manuscripts",
    "https://www.themorgan.org/manuscript",
    "https://www.themorgan.org/collection",
    "https://www.themorgan.org/manuscripts/coptic",
    "http://corsair.themorgan.org",
    "https://corsair.themorgan.org",
    "https://host.themorgan.org",
]

if __name__ == "__main__":
    a = [x for x in sys.argv[1:] if not x.startswith("--")]
    if not a:
        print("مفيش روابط → بستخدم نقاط البداية الافتراضية وأزحف منها لكل الموقع.")
        a = DEFAULT_SEEDS
    run(a)
