#!/usr/bin/env python3
"""Ava-Makar universal harvester: turn ANY IIIF source into a catalog for download_iiif.py.

Many big libraries (Morgan/Hamuli, Cambridge, Michigan, Harvard, Yale) block cloud
servers but NOT a home computer. Run this ON YOUR OWN COMPUTER to build a catalog,
then download with download_iiif.py.

Three ways to use it:

1) From a IIIF Collection manifest (one URL that lists many manuscripts):
     python harvest_collection.py --collection https://.../collection.json --library Morgan --out morgan.json

2) From a plain text file of manifest URLs (one per line; # comments allowed):
     python harvest_collection.py --list my_manifests.txt --library Cambridge --out cambridge.json

3) From a text file of viewer page URLs, auto-finding the manifest in each page:
     python harvest_collection.py --pages pages.txt --library Michigan --out michigan.json

Then:
     python download_iiif.py morgan.json --out G:/Coptic_Heritage
"""
import argparse, json, re, sys, time, urllib.request, urllib.error

try:
    import truststore; truststore.inject_into_ssl()
except ImportError:
    pass
for _s in (sys.stdout, sys.stderr):
    try: _s.reconfigure(encoding="utf-8", errors="replace")
    except Exception: pass

UA = "AvaMakar-Heritage/1.0 (monastery archive; polite)"


def get(url, tries=4, timeout=90):
    last = None
    for i in range(tries):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": UA})
            return urllib.request.urlopen(req, timeout=timeout).read()
        except urllib.error.HTTPError as e:
            if e.code in (404, 403, 401): raise
            last = e
        except Exception as e:
            last = e
        time.sleep(3 * (i + 1))
    raise last


def label_of(x):
    if isinstance(x, str): return x
    if isinstance(x, list):
        return label_of(x[0]) if x else ""
    if isinstance(x, dict):
        if "@value" in x: return x["@value"]
        for v in x.values():  # v3 language map {"en":["..."]}
            return label_of(v)
    return ""


def manifests_in_collection(url, depth=0):
    """Yield (manifest_url, label) from a IIIF Collection (v2 or v3), following sub-collections."""
    data = json.loads(get(url))
    # v2: "manifests":[{"@id","label"}], sub-collections in "collections" or "members"
    for m in data.get("manifests", []):
        yield m.get("@id") or m.get("id"), label_of(m.get("label"))
    # v3: "items":[{"id","type":"Manifest"|"Collection","label"}]
    for m in data.get("items", []):
        t = m.get("type") or m.get("@type", "")
        mid = m.get("id") or m.get("@id")
        if "Manifest" in t:
            yield mid, label_of(m.get("label"))
        elif "Collection" in t and depth < 4 and mid and mid != url:
            yield from manifests_in_collection(mid, depth + 1)
    for m in data.get("collections", []):
        mid = m.get("@id") or m.get("id")
        if depth < 4 and mid and mid != url:
            yield from manifests_in_collection(mid, depth + 1)


MANIFEST_RE = re.compile(r'https?://[^\s"\'<>]+?(?:/manifest(?:\.json)?|manifest=)[^\s"\'<>]*')


def manifest_in_page(url):
    html = get(url).decode("utf-8", "replace")
    m = MANIFEST_RE.search(html)
    return m.group(0).rstrip('",;') if m else None


def count_pages(manifest_url):
    try:
        d = json.loads(get(manifest_url))
        if "sequences" in d:
            return len(d["sequences"][0].get("canvases", []))
        return len(d.get("items", []))
    except Exception:
        return 0


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    g = ap.add_mutually_exclusive_group(required=True)
    g.add_argument("--collection", help="a IIIF Collection manifest URL")
    g.add_argument("--list", help="text file of manifest URLs, one per line")
    g.add_argument("--pages", help="text file of viewer-page URLs; the manifest is found inside each")
    ap.add_argument("--library", required=True, help="library name, e.g. Morgan")
    ap.add_argument("--collection-name", default="Coptic", help="collection folder name")
    ap.add_argument("--out", required=True, help="output catalog .json")
    ap.add_argument("--tier", type=int, default=1)
    ap.add_argument("--count-pages", action="store_true", help="also fetch each manifest to count pages (slower)")
    a = ap.parse_args()

    entries = []  # (manifest_url, label)
    if a.collection:
        print(f"Reading collection {a.collection} ...")
        entries = list(manifests_in_collection(a.collection))
    elif a.list:
        for line in open(a.list, encoding="utf-8"):
            u = line.strip()
            if u and not u.startswith("#"):
                entries.append((u, ""))
    else:
        for line in open(a.pages, encoding="utf-8"):
            u = line.strip()
            if not u or u.startswith("#"):
                continue
            try:
                m = manifest_in_page(u)
                print(("  found " if m else "  no manifest in ") + u)
                if m: entries.append((m, ""))
            except Exception as e:
                print("  ! ", u, e)
            time.sleep(0.5)

    out = []
    seen = set()
    for i, (murl, label) in enumerate(entries, 1):
        if not murl or murl in seen:
            continue
        seen.add(murl)
        if label:
            base = label
        else:  # derive from the URL: drop trailing /manifest or /manifest.json, take the distinctive segment
            segs = [s for s in re.sub(r"/manifest(\.json)?/?$", "", murl.split("?")[0]).split("/") if s]
            base = re.sub(r"\.json$", "", segs[-1]) if segs else murl
        sm = re.sub(r"[^A-Za-z0-9._-]+", "_", base).strip("_")[:80] or f"ms{i:04d}"
        rec = {"library": a.library, "collection": a.collection_name, "shelfmark": sm,
               "title": label, "tier": a.tier, "manifest": murl}
        if a.count_pages:
            rec["pages"] = count_pages(murl)
            print(f"  [{i}/{len(entries)}] {sm}: {rec['pages']} pages")
            time.sleep(0.3)
        out.append(rec)

    json.dump({"source": f"{a.library} harvest {time.strftime('%Y-%m-%d')}", "manuscripts": out},
              open(a.out, "w", encoding="utf-8"), ensure_ascii=False, indent=0)
    print(f"Saved {a.out}: {len(out)} manuscripts")


if __name__ == "__main__":
    main()
