#!/usr/bin/env python3
"""Build gallica_catalog.json (Coptic, Syriac and Ethiopic manuscripts of the BnF) from
Gallica's public SRU search API, for use with download_iiif.py.

Gallica blocks cloud servers, so run this ON YOUR OWN COMPUTER:
    python harvest_gallica.py
    python download_iiif.py gallica_catalog.json --out G:/Coptic_Heritage

Gallica terms: free non-commercial reuse with the mention
"Source gallica.bnf.fr / Bibliothèque nationale de France".
"""
import json, re, sys, time, urllib.parse, urllib.request, xml.etree.ElementTree as ET

try:
    import truststore
    truststore.inject_into_ssl()
except ImportError:
    pass
for _s in (sys.stdout, sys.stderr):
    try:
        _s.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

UA = "AvaMakar-Heritage/1.0 (monastery archive; polite)"
SRU = "https://gallica.bnf.fr/SRU"
QUERIES = {
    1: ['dc.type all "manuscrit" and gallica all "copte"'],
    2: ['dc.type all "manuscrit" and gallica all "syriaque"',
        'dc.type all "manuscrit" and gallica all "éthiopien"',
        'dc.type all "manuscrit" and gallica all "arabe chrétien"'],
}
NS = {"srw": "http://www.loc.gov/zing/srw/", "dc": "http://purl.org/dc/elements/1.1/"}


def get(url):
    for i in range(5):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": UA})
            return urllib.request.urlopen(req, timeout=90).read()
        except Exception as e:
            print("   retry:", e)
            time.sleep(5 * (i + 1))
    raise SystemExit("Gallica did not answer: " + url)


def main():
    items = {}
    for tier, qs in QUERIES.items():
        for q in qs:
            start = 1
            while True:
                url = SRU + "?" + urllib.parse.urlencode({
                    "operation": "searchRetrieve", "version": "1.2", "query": q,
                    "startRecord": start, "maximumRecords": 50})
                root = ET.fromstring(get(url))
                total = int(root.findtext("srw:numberOfRecords", "0", NS))
                recs = root.findall(".//srw:record", NS)
                for r in recs:
                    ids = [e.text or "" for e in r.iter("{http://purl.org/dc/elements/1.1/}identifier")]
                    ark = next((m.group(1) for i in ids for m in [re.search(r"(ark:/12148/[a-z0-9]+)", i)] if m), None)
                    if not ark:
                        continue
                    title = (r.findtext(".//dc:title", "", NS) or "")[:200]
                    src = (r.findtext(".//dc:source", "", NS) or "")[:120]
                    it = items.setdefault(ark, {
                        "library": "BnF_Gallica", "collection": "Coptic" if tier == 1 else "Eastern_Christian",
                        "shelfmark": (src or ark.split("/")[-1]).replace("/", "_"), "title": title, "tier": tier,
                        "manifest": f"https://gallica.bnf.fr/iiif/{ark}/manifest.json",
                        "viewer": f"https://gallica.bnf.fr/{ark}",
                        "rights": "Source gallica.bnf.fr / BnF. Free non-commercial reuse with attribution."})
                    it["tier"] = min(it["tier"], tier)
                print(f"{q}: {min(start + 49, total)}/{total}  (total unique {len(items)})")
                start += 50
                if start > total or not recs:
                    break
                time.sleep(1.5)
    out = sorted(items.values(), key=lambda i: (i["tier"], i["shelfmark"]))
    json.dump({"source": "Gallica SRU, " + time.strftime("%Y-%m-%d"), "manuscripts": out},
              open("gallica_catalog.json", "w", encoding="utf-8"), ensure_ascii=False, indent=0)
    print(f"Saved gallica_catalog.json: {len(out)} manuscripts")


if __name__ == "__main__":
    main()
