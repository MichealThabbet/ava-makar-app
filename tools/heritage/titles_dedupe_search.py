#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
يفحص كل ملفات .txt في نفس فولدر السكربت:
  1) يقرا كل سطر (كل سطر = عنوان أو عنوان + رابط).
  2) يطلّع المتكرر (نفس السطر في نفس الملف أو في ملفات مختلفة).
  3) يدوّر على النت على كل عنوان في 9 محركات بحث، ويجمع الروابط.
  4) يكتب ملف واحد: نتيجة_الفحص.csv (يفتح في Excel بالعربي).

التثبيت مرة واحدة:
    pip install ddgs

التشغيل (حط السكربت في نفس الفولدر اللي فيه ملفات التكست):
    python titles_dedupe_search.py

لو وقف في النص، شغّله تاني: بيكمّل من غير ما يعيد البحث عن العناوين اللي خلصت
(النتايج محفوظة في search_cache.json جنب السكربت).
"""
import csv, glob, json, os, re, sys, time, unicodedata
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))
OUT_CSV = os.path.join(HERE, "نتيجة_الفحص.csv")
CACHE = os.path.join(HERE, "search_cache.json")

ENGINES = ["google", "bing", "brave", "duckduckgo", "yahoo", "yandex", "mojeek", "startpage", "wikipedia"]
PER_ENGINE = 10        # نتايج من كل محرك
TOP_LINKS = 10         # عدد الروابط اللي تتكتب في أعمدة منفصلة
URL_RE = re.compile(r"https?://[^\s<>\"']+")
TASHKEEL = re.compile(r"[ؐ-ًؚ-ٰٟۖ-ۭـ]")


def read_text(path):
    raw = open(path, "rb").read()
    for enc in ("utf-8-sig", "utf-16", "cp1256", "latin-1"):
        try:
            t = raw.decode(enc)
            if enc == "utf-16" and not raw[:2] in (b"\xff\xfe", b"\xfe\xff"):
                continue
            return t
        except UnicodeDecodeError:
            continue
    return raw.decode("utf-8", "replace")


def norm(s):
    """توحيد بسيط عشان نكشف التكرار: مسافات، حروف كبيرة/صغيرة، تشكيل، تطويل."""
    s = unicodedata.normalize("NFC", s)
    s = TASHKEEL.sub("", s)
    s = re.sub(r"\s+", " ", s).strip().casefold()
    return s


def clean_url(u):
    return u.rstrip(".,;:)]}>»\"'")


# ───────────── 1) قراءة الملفات ─────────────
files = sorted(f for f in glob.glob(os.path.join(HERE, "*.txt")))
if not files:
    print("مفيش ملفات .txt في الفولدر:", HERE)
    input("Enter للخروج..."); sys.exit(1)

entries = {}        # المفتاح الموحّد -> بيانات
file_hash = {}
total_lines = 0
for f in files:
    name = os.path.basename(f)
    text = read_text(f)
    file_hash.setdefault(hash(text), []).append(name)
    for ln, line in enumerate(text.splitlines(), 1):
        line = line.strip()
        if not line:
            continue
        total_lines += 1
        urls = [clean_url(u) for u in URL_RE.findall(line)]
        title = URL_RE.sub(" ", line).strip(" -|–—\t,;:")
        title = re.sub(r"\s+", " ", title)
        key = norm(title) if title else norm(" ".join(urls))
        e = entries.setdefault(key, {"title": title or (urls[0] if urls else line),
                                     "places": [], "urls_in_file": []})
        e["places"].append(f"{name}:{ln}")
        for u in urls:
            if u not in e["urls_in_file"]:
                e["urls_in_file"].append(u)

dups = {k: v for k, v in entries.items() if len(v["places"]) > 1}
print(f"الملفات: {len(files)} | السطور: {total_lines} | عناوين مختلفة: {len(entries)} | "
      f"متكرر: {len(dups)} عنوان ({sum(len(v['places']) for v in dups.values())} سطر)")
same = [v for v in file_hash.values() if len(v) > 1]
for grp in same:
    print("  ملفات متطابقة بالكامل:", " = ".join(grp))

# ───────────── 2) البحث على النت ─────────────
try:
    from ddgs import DDGS
except ImportError:
    print("\nمحتاج تثبّت مكتبة البحث مرة واحدة:\n    pip install ddgs")
    input("Enter للخروج..."); sys.exit(1)

cache = json.load(open(CACHE, encoding="utf-8")) if os.path.exists(CACHE) else {}
engine_fail = {e: 0 for e in ENGINES}


def search_engine(engine, query):
    if engine_fail[engine] >= 5:          # محرك بيرفض باستمرار → نريّحه
        return engine, []
    for attempt in range(3):
        try:
            res = DDGS(timeout=20).text(query, max_results=PER_ENGINE, backend=engine) or []
            engine_fail[engine] = 0
            return engine, res
        except Exception as ex:
            msg = str(ex).lower()
            if "no results" in msg:
                return engine, []
            time.sleep(3 * (attempt + 1))
    engine_fail[engine] += 1
    return engine, []


def deep_search(title):
    found = {}     # url -> {title, engines}

    def add(engine, res):
        for r in res:
            u = clean_url(r.get("href") or r.get("url") or "")
            if not u.startswith("http"):
                continue
            d = found.setdefault(u, {"title": (r.get("title") or "").strip(), "engines": set()})
            d["engines"].add(engine)

    # أولاً: العنوان بالظبط بين علامتين تنصيص، في كل المحركات مع بعض
    with ThreadPoolExecutor(len(ENGINES)) as ex:
        for eng, res in ex.map(lambda e: search_engine(e, f'"{title}"'), ENGINES):
            add(eng, res)
    # لو النتايج قليلة: نفس العنوان من غير تنصيص
    if len(found) < 5:
        with ThreadPoolExecutor(len(ENGINES)) as ex:
            for eng, res in ex.map(lambda e: search_engine(e, title), ENGINES):
                add(eng, res)
    ranked = sorted(found.items(), key=lambda kv: -len(kv[1]["engines"]))
    return [{"url": u, "title": d["title"], "engines": sorted(d["engines"])} for u, d in ranked]


todo = [k for k in entries if k not in cache and entries[k]["title"] and not entries[k]["title"].startswith("http")]
print(f"\nالبحث على النت: {len(todo)} عنوان (و{len(entries) - len(todo)} محفوظين من قبل أو روابط بس)")
for i, k in enumerate(todo, 1):
    t = entries[k]["title"]
    cache[k] = deep_search(t)
    ok_eng = [e for e in ENGINES if engine_fail[e] < 5]
    print(f"  [{i}/{len(todo)}] {len(cache[k]):3} رابط | {t[:70]}")
    if i % 5 == 0 or i == len(todo):
        json.dump(cache, open(CACHE, "w", encoding="utf-8"), ensure_ascii=False)
    if not ok_eng:
        print("\nكل المحركات رافضة دلوقتي (غالباً كتر الطلبات). استنى شوية وشغّل السكربت تاني، هيكمّل.")
        break
json.dump(cache, open(CACHE, "w", encoding="utf-8"), ensure_ascii=False)

# ───────────── 3) ملف CSV واحد ─────────────
order = sorted(entries.items(), key=lambda kv: (-len(kv[1]["places"]),
               files.index(os.path.join(HERE, kv[1]["places"][0].rsplit(":", 1)[0])),
               int(kv[1]["places"][0].rsplit(":", 1)[1])))
head = ["رقم", "العنوان", "عدد_مرات_التكرار", "متكرر", "الملفات_والسطور", "روابط_موجودة_في_الملف",
        "عدد_الروابط_من_البحث"]
for n in range(1, TOP_LINKS + 1):
    head += [f"رابط_{n}", f"عنوان_النتيجة_{n}", f"المحركات_{n}"]
head += ["كل_روابط_البحث", "حالة_البحث"]

with open(OUT_CSV, "w", newline="", encoding="utf-8-sig") as fh:
    w = csv.writer(fh)
    w.writerow(head)
    for idx, (k, e) in enumerate(order, 1):
        res = cache.get(k)
        status = ("لسه مااتبحثش" if res is None else "مفيش نتايج" if not res else "تم")
        if res is None and e["title"].startswith("http"):
            status = "السطر رابط بس"
        res = res or []
        row = [idx, e["title"], len(e["places"]), "نعم" if len(e["places"]) > 1 else "لا",
               " ، ".join(e["places"]), " ".join(e["urls_in_file"]), len(res)]
        for n in range(TOP_LINKS):
            if n < len(res):
                row += [res[n]["url"], res[n]["title"], "+".join(res[n]["engines"])]
            else:
                row += ["", "", ""]
        row += [" ".join(r["url"] for r in res), status]
        w.writerow(row)

print(f"\nخلص. الملف: {OUT_CSV}")
print(f"  {len(entries)} عنوان، منهم {len(dups)} متكرر (في أول الجدول).")
not_done = sum(1 for k in entries if k not in cache and not entries[k]["title"].startswith("http"))
if not_done:
    print(f"  {not_done} عنوان لسه مااتبحثش — شغّل السكربت تاني يكمّلهم.")
input("Enter للخروج...")
