#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""مرجان (themorgan.org): بيطلّع روابط Zoomify لكل صفحة مخطوط، وبيجهّز أوامر
dezoomify-rs اللي بتلحّم الـtiles وترجّع الصورة فل دقة (مش الـ1500 الجاهزة بس).

التشغيل على جهازك (متصفح حقيقي):
    pip install playwright && playwright install chromium
    python harvest_morgan.py "https://www.themorgan.org/manuscript/<id>"
    python harvest_morgan.py --col "https://www.themorgan.org/collection/<name>"

بيطلّع: morgan_zoomify.txt (رابط ImageProperties.xml لكل صفحة)
بعدها نزّل dezoomify-rs وشغّل:
    dezoomify-rs -l morgan_zoomify.txt out/
"""
import re, sys, time, os
HERE=os.path.dirname(os.path.abspath(__file__)); OUT=os.path.join(HERE,"morgan_zoomify.txt")

def run(seeds, is_col):
    from playwright.sync_api import sync_playwright
    found=[]
    with sync_playwright() as pw:
        b=pw.chromium.launch(headless=False); pg=b.new_page()
        # لو مجموعة: اجمع روابط الصفحات الفردية الأول
        targets=[]
        for s in seeds:
            pg.goto(s, wait_until="domcontentloaded", timeout=90000); time.sleep(2)
            if is_col:
                links=pg.eval_on_selector_all("a[href*='/manuscript/'],a[href*='/collection/']",
                    "els=>els.map(e=>e.href)")
                targets+=sorted(set(links))
            else:
                targets.append(s)
        print("صفحات:",len(targets))
        for t in targets:
            try:
                pg.goto(t, wait_until="domcontentloaded", timeout=90000); time.sleep(1.5)
                html=pg.content()
                # Zoomify بيحط ImageProperties.xml أو مسار zoomify في الصفحة/الشبكة
                m=re.findall(r'(https?://[^"\']+?(?:ImageProperties\.xml|/zoomify/[^"\']+))',html)
                # كمان من روابط الصور المتقطّعة
                m+=re.findall(r'(https?://[^"\']+?/TileGroup\d+/[^"\']+)',html)
                for u in m:
                    base=u.split("TileGroup")[0].rstrip("/")
                    ip=base+"/ImageProperties.xml" if "ImageProperties" not in u else u
                    if ip not in found: found.append(ip)
                print(f"  {t[-40:]}  →  {len(found)} صورة")
            except Exception as e:
                print("  خطأ:",repr(e)[:60])
        b.close()
    open(OUT,"w").write("\n".join(found))
    print(f"\nاتحفظ {len(found)} رابط في {OUT}")
    print("نزّل dezoomify-rs وشغّل:  dezoomify-rs -l morgan_zoomify.txt out/")

if __name__=="__main__":
    a=[x for x in sys.argv[1:] if not x.startswith("--")]
    if not a: print("حط رابط مخطوط أو --col ورابط مجموعة"); sys.exit(1)
    run(a, "--col" in sys.argv)
