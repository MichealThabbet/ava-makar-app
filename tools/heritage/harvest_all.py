#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""الضربة القاضية: حصّاد شامل بمتصفح حقيقي (Playwright) يعدّي Cloudflare،
يحصد كل مكتبة *خام كامل* (من غير ما يرمي أي سجل وهو بيحصد)، ويحفظ في raw/<lib>.json.
الفلترة المسيحية بتتعمل بعدين بسكربت منفصل (filter_christian.py) عشان نقدر نراجع
ونتأكد إننا مش بنفوّت حاجة.

تثبيت مرة واحدة على جهازك:
    pip install playwright
    playwright install chromium

التشغيل:
    python harvest_all.py              # كل المكتبات في SOURCES
    python harvest_all.py laurenziana  # مكتبة واحدة بالاسم
    python harvest_all.py --list       # اعرض المكتبات المتاحة

بيفتح نافذة Chrome (سيبها مفتوحة). كل مكتبة بتتحفظ خام في raw/.
السكربت resumable: لو وقف، شغّله تاني يكمّل من آخر صفحة اتحفظت.
"""
import re, json, os, sys, time, urllib.parse

HERE = os.path.dirname(os.path.abspath(__file__))
RAW = os.path.join(HERE, "raw")
os.makedirs(RAW, exist_ok=True)

# ───────────────────────── لستة الأهداف ─────────────────────────
# type: "oai"        → OAI-PMH ListRecords (ContentDM وغيره). endpoint=base oai.php ، set=اسم المجموعة
#       "iiif_coll"  → IIIF Collection JSON ، بنمشي على كل manifest فيها (ومجموعاتها الفرعية)
#       "blacklight" → كتالوج Blacklight ، endpoint=.../catalog.json
# raw بيحتوي كل سجل {id,title,manifest} من غير فلتر.
SOURCES = [
    # ── ContentDM / OAI-PMH (كلها Cloudflare-gated → محتاجة متصفح) ──
    {"name": "laurenziana", "type": "oai", "library": "Biblioteca Medicea Laurenziana, Florence",
     "endpoint": "https://cdm21059.contentdm.oclc.org/oai/oai.php", "set": "plutei",
     "manifest": "https://cdm21059.contentdm.oclc.org/iiif/plutei:{id}/manifest.json"},
    {"name": "claremont_cce", "type": "oai", "library": "Claremont Colleges (CCE)",
     "endpoint": "https://cdm15831.contentdm.oclc.org/oai/oai.php", "set": "p15831coll13",
     "manifest": "https://cdm15831.contentdm.oclc.org/iiif/2/p15831coll13:{id}/manifest.json"},
    {"name": "watson_met", "type": "oai", "library": "Metropolitan Museum — Watson Library",
     "endpoint": "https://libmma.contentdm.oclc.org/oai/oai.php", "set": "p16028coll6",
     "manifest": "https://libmma.contentdm.oclc.org/iiif/info/p16028coll6/{id}/manifest.json"},
    {"name": "watson_kharga", "type": "oai", "library": "Metropolitan Museum — Watson (Kharga)",
     "endpoint": "https://libmma.contentdm.oclc.org/oai/oai.php", "set": "p16028coll10",
     "manifest": "https://libmma.contentdm.oclc.org/iiif/info/p16028coll10/{id}/manifest.json"},
    {"name": "claremont_aot", "type": "oai", "library": "Claremont Colleges (AOT)",
     "endpoint": "https://cdm15831.contentdm.oclc.org/oai/oai.php", "set": "aot",
     "manifest": "https://cdm15831.contentdm.oclc.org/iiif/aot:{id}/manifest.json"},
    {"name": "claremont_bia", "type": "oai", "library": "Claremont Colleges (BIA)",
     "endpoint": "https://cdm15831.contentdm.oclc.org/oai/oai.php", "set": "bia",
     "manifest": "https://cdm15831.contentdm.oclc.org/iiif/bia:{id}/manifest.json"},
    {"name": "claremont_nha", "type": "oai", "library": "Claremont Colleges (NHA)",
     "endpoint": "https://cdm15831.contentdm.oclc.org/oai/oai.php", "set": "nha",
     "manifest": "https://cdm15831.contentdm.oclc.org/iiif/nha:{id}/manifest.json"},

    # ── IIIF Collections (بعضها Cloudflare، بعضها لأ — المتصفح بيعدّي الكل) ──
    {"name": "bodleian", "type": "iiif_coll", "library": "Bodleian Library, Oxford",
     "endpoint": "https://iiif.bodleian.ox.ac.uk/iiif/collection/top.json"},
    {"name": "sinai_ucla", "type": "blacklight", "library": "St Catherine's Sinai (UCLA)",
     "endpoint": "https://sinaimanuscripts.library.ucla.edu/catalog.json", "q": ""},
    {"name": "vatican", "type": "iiif_coll", "library": "Biblioteca Apostolica Vaticana",
     "endpoint": "https://digi.vatlib.it/iiif/collection"},
    {"name": "wellcome", "type": "iiif_coll", "library": "Wellcome Collection",
     "endpoint": "https://iiif.wellcomecollection.org/presentation/v2/collections/genres"},

    # ── Blacklight catalog.json ──
    {"name": "princeton_figgy", "type": "blacklight", "library": "Princeton (Figgy)",
     "endpoint": "https://catalog.princeton.edu/catalog.json", "q": "coptic manuscript"},
]

SRC = {s["name"]: s for s in SOURCES}

# ───────────────────────── المتصفح ─────────────────────────
def make_browser(pw):
    b = pw.chromium.launch(headless=False)
    return b, b.new_page()

def get_text(page, url, needle_any):
    """يفتح url ويستنى Cloudflare يعدّي لحد ما يلاقي واحدة من needle_any."""
    page.goto(url, wait_until="domcontentloaded", timeout=90000)
    for _ in range(25):
        t = page.content()
        if any(n in t for n in needle_any):
            return t
        time.sleep(1.2)
    return page.content()

def get_json(page, url):
    """بيجيب JSON من رد التنقّل نفسه (مفيش CORS). لو فيه حماية بيستنّاها."""
    try:
        resp = page.goto(url, wait_until="domcontentloaded", timeout=90000)
    except Exception as e:
        print("   goto err:", repr(e)[:80]); return ""
    for _ in range(25):
        try:
            body = page.evaluate("() => document.body ? document.body.innerText : ''")
        except Exception:
            body = ""
        if body and ("{" in body[:200] or "[" in body[:200]) and "just a moment" not in body.lower():
            return body
        # ساعات الرد مش HTML، جرّب من الـresponse مباشرة
        try:
            if resp:
                t = resp.text()
                if t and ("{" in t[:200] or "[" in t[:200]):
                    return t
        except Exception:
            pass
        time.sleep(1.2)
    print("   تحذير: الرد مش JSON (حماية/رابط غلط). أول 120 حرف:", (body or "")[:120])
    return body or ""

# ───────────────────────── الحفظ (resumable) ─────────────────────────
def load_raw(name):
    p = os.path.join(RAW, name + ".json")
    if os.path.exists(p):
        try: return json.load(open(p, encoding="utf-8"))
        except Exception: pass
    return {"name": name, "records": [], "done": False, "cursor": None}

def save_raw(d):
    json.dump(d, open(os.path.join(RAW, d["name"] + ".json"), "w", encoding="utf-8"),
              ensure_ascii=False, indent=1)

# ───────────────────────── حصّادات لكل نوع ─────────────────────────
def harvest_oai(page, s, state):
    base, lib = s["endpoint"], s["library"]
    seen = {r["id"] for r in state["records"]}
    tok = state.get("cursor")
    while True:
        if tok:
            url = f"{base}?verb=ListRecords&resumptionToken={urllib.parse.quote(tok)}"
        else:
            url = f"{base}?verb=ListRecords&metadataPrefix=oai_qdc&set={s['set']}"
        xml = get_text(page, url, ["<record", "&lt;record", "noRecordsMatch", "<OAI-PMH"])
        recs = re.findall(r"&lt;record&gt;.*?&lt;/record&gt;|<record>.*?</record>", xml, re.S) \
               or re.findall(r"<record.*?</record>", xml, re.S)
        for rec in recs:
            r = rec.replace("&lt;", "<").replace("&gt;", ">").replace("&amp;", "&")
            mid = re.search(r"(?:/|:)(\d+)(?:</|'|\")", r) or re.search(r"(\d{3,})", r)
            title = re.search(r"<dc:title>(.*?)</dc:title>", r, re.S)
            if not mid:
                continue
            i = mid.group(1)
            if i in seen:
                continue
            seen.add(i)
            t = re.sub(r"\s+", " ", (title.group(1) if title else "")).strip()
            state["records"].append({"id": i, "title": t[:200], "library": lib,
                                     "manifest": s["manifest"].format(id=i)})
        m = re.search(r"(?:&lt;|<)resumptionToken[^&<]*(?:&gt;|>)([^&<]+)", xml)
        tok = m.group(1).strip() if m and m.group(1).strip() else None
        state["cursor"] = tok
        save_raw(state)
        print(f"   {s['name']}: خام={len(state['records'])}  token={'نعم' if tok else 'خلص'}")
        if not tok:
            state["done"] = True; save_raw(state); return

def _collect_iiif(page, url, lib, state, seen, depth=0):
    if depth > 6:
        return
    raw = get_json(page, url)
    try:
        j = json.loads(raw)
    except Exception:
        return
    items = j.get("items") or j.get("manifests") or j.get("members") or []
    for it in items:
        typ = (it.get("type") or it.get("@type") or "").lower()
        iid = it.get("id") or it.get("@id") or ""
        lbl = it.get("label")
        if isinstance(lbl, dict):
            lbl = " ".join(sum(lbl.values(), [])) if lbl else ""
        lbl = re.sub(r"\s+", " ", str(lbl or "")).strip()
        if "collection" in typ:
            _collect_iiif(page, iid, lib, state, seen, depth + 1)
        elif iid and iid not in seen:
            seen.add(iid)
            state["records"].append({"id": iid, "title": lbl[:200], "library": lib, "manifest": iid})
    state["cursor"] = url
    save_raw(state)
    print(f"   iiif {url[-40:]}: خام={len(state['records'])}")

def harvest_iiif_coll(page, s, state):
    seen = {r["id"] for r in state["records"]}
    _collect_iiif(page, s["endpoint"], s["library"], state, seen)
    if not state["records"]:
        print(f"   {s['name']}: طلّع صفر — يا الرابط غلط يا الـcollection فاضية. "
              f"جرّب تفتح {s['endpoint']} في المتصفح وتشوف.")
    state["done"] = True; save_raw(state)

def harvest_blacklight(page, s, state):
    seen = {r["id"] for r in state["records"]}
    pageno = (len(state["records"]) // 100) + 1
    while True:
        url = f"{s['endpoint']}?q={urllib.parse.quote(s.get('q',''))}&per_page=100&page={pageno}"
        raw = get_json(page, url)
        try:
            j = json.loads(raw)
        except Exception:
            break
        data = j.get("data") or j.get("response", {}).get("docs") or []
        if not data:
            print(f"   {s['name']}: صفحة {pageno} مفيش داتا — بوقف."); break
        for d in data:
            a = d.get("attributes", d)  # بعض كتالوجات Blacklight مفيهاش attributes
            iid = d.get("id", "")
            if iid in seen:
                continue
            seen.add(iid)
            def val(x):
                if isinstance(x, dict):
                    return (x.get("attributes", {}) or {}).get("value", x.get("value", ""))
                return x
            t = val(a.get("title", "")) or val(a.get("title_display", ""))
            man = val(a.get("manifest", "")) or val(a.get("manifest_url", ""))
            state["records"].append({"id": iid, "title": re.sub(r"\s+"," ",str(t or ""))[:200],
                                     "library": s["library"], "manifest": man or ""})
        save_raw(state)
        print(f"   {s['name']}: صفحة {pageno} خام={len(state['records'])}")
        total = (j.get("meta", {}).get("pages", {}) or {}).get("total_count") \
                or j.get("response", {}).get("numFound")
        pageno += 1
        if total and len(state["records"]) >= int(total):
            break
        if pageno > 500:
            break
    state["done"] = True; save_raw(state)

HANDLERS = {"oai": harvest_oai, "iiif_coll": harvest_iiif_coll, "blacklight": harvest_blacklight}

# ───────────────────────── main ─────────────────────────
def run(names):
    try:
        from playwright.sync_api import sync_playwright
    except ImportError:
        print("محتاج تثبّت:\n  pip install playwright\n  playwright install chromium"); return
    with sync_playwright() as pw:
        browser, page = make_browser(pw)
        for nm in names:
            s = SRC[nm]
            st = load_raw(nm)
            if st.get("done"):
                print(f"✓ {nm}: متحصود خلاص ({len(st['records'])} خام). امسح raw/{nm}.json لو عايز تعيد.")
                continue
            print(f"▶ بحصد {nm} ({s['type']}) ...")
            try:
                HANDLERS[s["type"]](page, s, st)
                print(f"✔ {nm}: خلص — {len(st['records'])} سجل خام في raw/{nm}.json")
            except Exception as e:
                print(f"✗ {nm}: وقف — {repr(e)[:120]}. اتحفظ اللي اتحصد. شغّل تاني يكمّل.")
        browser.close()

if __name__ == "__main__":
    args = [a for a in sys.argv[1:] if not a.startswith("-")]
    if "--list" in sys.argv:
        for s in SOURCES:
            print(f"  {s['name']:18} {s['type']:11} {s['library']}")
        sys.exit(0)
    run(args or [s["name"] for s in SOURCES])
    print("\nخلاص الحصاد الخام. دلوقتي شغّل:  python filter_christian.py")
