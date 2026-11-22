#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""تشخيص: يجرّب يوصل لـOAI لورنتسيانا ويطبع بالظبط إيه اللي رجع.
التشغيل:  python test_laurenziana.py
"""
import urllib.request, ssl
try:
    import truststore; truststore.inject_into_ssl()
except Exception:
    pass

URL = ("https://cdm21059.contentdm.oclc.org/oai/oai.php"
       "?verb=ListRecords&metadataPrefix=oai_qdc&set=plutei")
# User-Agent متصفح حقيقي كامل
UA = ("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
      "(KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36")
HEADERS = {
    "User-Agent": UA,
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.9",
}

print("بجرّب أوصل لـ:", URL[:60], "...")
try:
    req = urllib.request.Request(URL, headers=HEADERS)
    with urllib.request.urlopen(req, timeout=60) as r:
        code = r.status
        body = r.read().decode("utf-8", "ignore")
    print("HTTP:", code)
    print("حجم الرد:", len(body), "حرف")
    low = body.lower()
    if "just a moment" in low or "cloudflare" in low or "cf-challenge" in low:
        print(">>> النتيجة: Cloudflare بيحجب (تحدّي متصفح). محتاجين طريقة تانية.")
    elif "<record>" in body:
        print(">>> النتيجة: شغّال! فيه سجلات:", body.count("<record>"), "في الدفعة دي")
        print(">>> يبقى نكمّل بالسكربت الكامل.")
    else:
        print(">>> رد غير متوقع. أول 400 حرف:")
        print(body[:400])
except Exception as e:
    print("خطأ في الاتصال:", repr(e)[:200])
    print(">>> يعني الطلب نفسه فشل (مش بس فاضي).")

input("\nاضغط Enter للخروج...")
