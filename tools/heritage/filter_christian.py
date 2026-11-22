#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""ياخد كل ملفات raw/*.json (الخام الكامل) ويفلتر التراث المسيحي حسب الاسكوب:
مسيحي بكل اللغات (قبطي/عربي مسيحي/يوناني ليتورجي/سرياني/حبشي/أرمني/جورجي/لاتيني كنسي)،
ويستبعد: اليهودي (عبري/جنيزة) والإسلامي (قرآن/فقه) والعلماني الكلاسيكي (فلسفة/أدب/قانون).

بيطلّع لكل مكتبة 3 ملفات في filtered/:
  <lib>.keep.json     = المقبول (مسيحي)
  <lib>.maybe.json    = مشكوك فيه (عنوان فاضي/مش واضح) ← راجعه بإيدك
  <lib>.drop.json     = المرفوض (علماني/يهودي/إسلامي) ← عشان تتأكد إننا صح

التشغيل:  python filter_christian.py
"""
import re, json, os, glob

HERE = os.path.dirname(os.path.abspath(__file__))
RAW = os.path.join(HERE, "raw")
OUT = os.path.join(HERE, "filtered"); os.makedirs(OUT, exist_ok=True)

CHRIST = re.compile(r"evangel|gospel|psalter|psalm|biblia|\bbible|testament|lectionar|"
    r"preces|euchai|eucholog|homili|omilia|sermon|logoi theioi|martyr|athleseis|"
    r"vita|vitae|synax|menolog|menaion|triodion|pentecostar|horolog|liturg|missal|"
    r"breviar|gradual|antiphon|hymn|theolog|patr|nysse|damasc|chrysost|basili|"
    r"gregor|theodoret|theodorit|ephrem|severus|cyril|athanas|apocalyp|"
    r"acta|passio|church|eccles|monast|coptic|copt|syriac|syriac|aethiop|ethiop|"
    r"ge.?ez|armen|georgian|iberic|christ", re.I)

SECULAR = re.compile(r"plato|politeia|parmenid|aristot|\bethica|pausania|xenoph|odyss|"
    r"\bhomer|iliad|aesop|phrygis|heliodor|aethiopica|avicenn|averro|harmenopul|"
    r"\biuris|\blex\b|graecism|erotemat|boccacc|\bcaesar|leonardi arret|libani|"
    r"aeschin|demosthen|thucydid|herodot|astronom|magica|de anima|meteor|"
    r"geometr|arithmet|medic|hippocrat|galen|dioscorid|lexic|dictionar|grammat|"
    r"rhetoric|comoedi|tragoedi|epigramm|satir|poetae", re.I)

JEW_ISL = re.compile(r"coran|qur|islam|alcoran|arabic philosoph|hadith|fiqh|"
    r"ebraic|hebrew|hebraic|talmud|genizah|judaeo|judeo|torah|midrash", re.I)

def classify(t):
    t = t or ""
    if JEW_ISL.search(t):   return "drop"
    if SECULAR.search(t):   return "drop"
    if CHRIST.search(t):    return "keep"
    if len(t.strip()) < 4:  return "maybe"   # عنوان فاضي → راجعه
    return "maybe"                            # مش متأكد → راجعه (مش بنرميه)

TIER = {"copt":1,"syriac":1,"aethiop":1,"ethiop":1,"ge":1,"armen":1,"georgian":1,
        "greek":2,"graec":2,"latin":3}

grand = {"keep":0,"maybe":0,"drop":0}
rows = []
for p in sorted(glob.glob(os.path.join(RAW, "*.json"))):
    d = json.load(open(p, encoding="utf-8"))
    name = d.get("name", os.path.basename(p)[:-5])
    buckets = {"keep":[], "maybe":[], "drop":[]}
    for r in d.get("records", []):
        buckets[classify(r.get("title",""))].append(r)
    for b in buckets:
        if buckets[b]:
            json.dump({"name":name,"bucket":b,"manuscripts":buckets[b]},
                open(os.path.join(OUT, f"{name}.{b}.json"),"w",encoding="utf-8"),
                ensure_ascii=False, indent=1)
    for k in grand: grand[k]+=len(buckets[k])
    rows.append((name, len(d.get("records",[])), len(buckets["keep"]),
                 len(buckets["maybe"]), len(buckets["drop"])))

print(f"{'مكتبة':20}{'خام':>8}{'مقبول':>8}{'مراجعة':>8}{'مرفوض':>8}")
print("-"*52)
for n,raw,k,m,dr in rows:
    print(f"{n:20}{raw:>8}{k:>8}{m:>8}{dr:>8}")
print("-"*52)
print(f"{'الإجمالي':20}{sum(r[1] for r in rows):>8}{grand['keep']:>8}{grand['maybe']:>8}{grand['drop']:>8}")
print(f"\nالملفات في: {OUT}")
print("راجع *.maybe.json (المشكوك) و *.drop.json (المرفوض) عشان تتأكد مفيش مسيحي اترمى بالغلط.")
