#!/usr/bin/env python3
"""Ava-Makar — Morgan Library downloader (RUN ON YOUR OWN COMPUTER).

The Morgan site blocks cloud servers, but opens normally on a home computer.
It serves each manuscript page as a direct image:

    https://www.themorgan.org/sites/default/files/facsimile/<ID>/<ID>{r|v}_<NNNN>.jpg

This tool finds Coptic/Hamuli manuscript IDs and downloads every page of each.

USAGE (on your computer, after installing Python):

  1) If you have a Morgan collection/search page open (e.g. a "Coptic" search),
     copy its address and let the tool read the manuscript IDs from it:

       python harvest_morgan.py --collection "https://www.themorgan.org/manuscripts/..." --out G:/Coptic_Heritage

  2) Or give the manuscript IDs yourself (the numbers in the page URL, e.g. 77452 77431):

       python harvest_morgan.py --ids 77452 77431 77452 --out G:/Coptic_Heritage

  3) Or put one ID per line in a text file:

       python harvest_morgan.py --ids-file morgan_ids.txt --out G:/Coptic_Heritage

Safe to stop (Ctrl+C) and run again: finished pages are skipped.
Images are © The Morgan Library & Museum — keep them for study and archive.
"""
import argparse, os, re, sys, time, urllib.request, urllib.error

try:
    import truststore; truststore.inject_into_ssl()
except ImportError:
    pass
for _s in (sys.stdout, sys.stderr):
    try: _s.reconfigure(encoding="utf-8", errors="replace")
    except Exception: pass

UA = "Mozilla/5.0 (compatible; AvaMakar-Heritage/1.0; monastery archive)"
BASE = "https://www.themorgan.org"
FAC = BASE + "/sites/default/files/facsimile/{id}/{id}{side}_{n:04d}.jpg"
FAC_PLAIN = BASE + "/sites/default/files/facsimile/{id}/{id}_{n:04d}.jpg"


def fetch(url, tries=4, timeout=90):
    last = None
    for i in range(tries):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": UA})
            with urllib.request.urlopen(req, timeout=timeout) as r:
                return r.read()
        except urllib.error.HTTPError as e:
            if e.code in (403, 404):
                raise
            last = e
        except Exception as e:
            last = e
        time.sleep(3 * (i + 1))
    raise last


# Coptic-DISCRIMINATING search terms (broad but not flooded with non-Coptic Morgan items).
# Dialects, Egyptian monasteries/places, and distinctly Coptic saints — many spellings.
COPTIC_TERMS = [
    "Coptic", "Coptic-Arabic", "Bohairic", "Sahidic", "Fayyumic", "Akhmimic", "Mesokemic",
    "Hamuli", "Fayyum", "Scetis", "Wadi Natrun", "Nitria", "Kellia",
    "White Monastery", "Atripe", "Bawit", "Esna", "Edfu", "Thebes", "Aswan",
    "Monastery of Saint Macarius", "Dayr Anba Maqar", "Monastery of the Archangel Michael",
    "Monastery of Apa Jeremias", "Saqqara", "Phantou", "Sopehes",
    "Shenoute", "Shenute", "Besa", "Pachomius", "Pshoi", "Bishoi", "Macarius",
    "Pisentius", "Pesynthius", "Mercurius", "Claudius", "Theodore the Anatolian",
    "Apa Apollo", "Apa Phib", "Victor of Antioch", "Mena", "Menas", "Psote",
    "Coptic papyrus", "Coptic manuscript", "Coptic gospel", "Coptic lectionary",
    "Egypt Christian", "Egyptian monastery",
]


def discover_ids(url):
    """Read a Morgan collection/search HTML page and pull manuscript IDs + titles."""
    html = fetch(url).decode("utf-8", "replace")
    ids = {}
    # links like /collection/<slug>/<ID> or /collection/<slug>/<ID>/<page> or /manuscript/<ID>
    for m in re.finditer(r'/(?:collection/[^"\'/]+|manuscript)/(\d+)', html):
        ids.setdefault(m.group(1), "")
    return list(ids)


def discover_broad(template, pause=1.0):
    """Run a Morgan search for every Coptic term and aggregate manuscript IDs.
    `template` is a search URL with {term} where the query goes, e.g.
      https://www.themorgan.org/search?search_api_fulltext={term}
    Paginates each term while new IDs keep appearing."""
    import urllib.parse
    allids = {}
    for term in COPTIC_TERMS:
        q = urllib.parse.quote(term)
        page = 0
        while True:
            sep = "&" if "?" in template else "?"
            url = template.format(term=q) + f"{sep}page={page}"
            try:
                found = discover_ids(url)
            except Exception as e:
                print(f"   ! search '{term}' p{page}: {e}"); break
            new = [i for i in found if i not in allids]
            for i in found:
                allids[i] = term
            print(f"   '{term}' p{page}: {len(found)} hits, {len(new)} new (total {len(allids)})")
            if not new or page > 25:
                break
            page += 1
            time.sleep(pause)
        time.sleep(pause)
    return list(allids)


def pages_for(mid):
    """Find every page image of a manuscript by probing the facsimile pattern."""
    urls = []
    # Morgan pages are usually recto/verso per leaf; some objects use a plain suffix.
    # Probe n=1.. for r,v (and plain); stop after several empty leaves in a row.
    misses = 0
    n = 1
    plain_mode = None  # None=unknown, True=use plain, False=use r/v
    while misses < 4 and n <= 2000:
        found_this = False
        candidates = ([FAC_PLAIN.format(id=mid, n=n)] if plain_mode else
                      [FAC.format(id=mid, side="r", n=n), FAC.format(id=mid, side="v", n=n)])
        if plain_mode is None:
            candidates = [FAC.format(id=mid, side="r", n=n), FAC.format(id=mid, side="v", n=n),
                          FAC_PLAIN.format(id=mid, n=n)]
        for u in candidates:
            try:
                req = urllib.request.Request(u, headers={"User-Agent": UA, "Range": "bytes=0-0"})
                urllib.request.urlopen(req, timeout=40).read(1)
                urls.append(u.split("?")[0])
                found_this = True
                if plain_mode is None:
                    plain_mode = "_%04d.jpg" % n in u
            except Exception:
                continue
        if found_this:
            misses = 0
        else:
            misses += 1
        n += 1
    return urls


def download(mid, title, out, pause):
    folder = os.path.join(out, "Morgan", (re.sub(r"[^A-Za-z0-9._-]+", "_", title)[:50] + "_" if title else "") + str(mid))
    os.makedirs(folder, exist_ok=True)
    urls = pages_for(mid)
    if not urls:
        print(f"   {mid}: no images found (check the ID, or the site may require a page visit first)")
        return False
    with open(os.path.join(folder, "info.txt"), "w", encoding="utf-8") as f:
        f.write(f"morgan_id: {mid}\ntitle: {title}\npages: {len(urls)}\n")
        f.write("rights: The Morgan Library & Museum. Study/archive use.\n")
    done = 0
    for i, u in enumerate(urls, 1):
        dest = os.path.join(folder, f"{i:04d}.jpg")
        if os.path.exists(dest) and os.path.getsize(dest) > 1000:
            done += 1; continue
        try:
            data = fetch(u, timeout=300)
        except Exception as e:
            print(f"   ! page {i} failed: {e}"); continue
        with open(dest + ".part", "wb") as f:
            f.write(data)
        os.replace(dest + ".part", dest)
        done += 1
        print(f"\r   {mid}: {done}/{len(urls)} pages", end="", flush=True)
        time.sleep(pause)
    print(f"\r   {mid}: {done}/{len(urls)} pages" + (" \u2713" if done == len(urls) else " (run again to finish)"))
    return done == len(urls)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    g = ap.add_mutually_exclusive_group(required=True)
    g.add_argument("--collection", help="a Morgan collection/search page URL to read manuscript IDs from")
    g.add_argument("--broad", action="store_true",
                   help="search Morgan for ALL Coptic terms (dialects, monasteries, saints) and download everything found")
    g.add_argument("--ids", nargs="+", help="manuscript IDs (the numbers in the page URL)")
    g.add_argument("--ids-file", help="a text file with one manuscript ID per line")
    ap.add_argument("--out", required=True, help="destination folder, e.g. G:/Coptic_Heritage")
    ap.add_argument("--search-template",
                    default="https://www.themorgan.org/search?search_api_fulltext={term}",
                    help="Morgan search URL with {term} placeholder (adjust if Morgan's search address differs)")
    ap.add_argument("--list-only", action="store_true", help="only find and print IDs, do not download")
    ap.add_argument("--pause", type=float, default=0.5, help="seconds between pages")
    a = ap.parse_args()

    if a.broad:
        print("Broad Coptic search across Morgan (all terms) ...")
        ids = discover_broad(a.search_template, pause=max(a.pause, 1.0))
    elif a.collection:
        print(f"Reading manuscript IDs from {a.collection} ...")
        ids = discover_ids(a.collection)
    elif a.ids_file:
        ids = [l.strip() for l in open(a.ids_file, encoding="utf-8") if l.strip() and not l.startswith("#")]
    else:
        ids = a.ids
    ids = list(dict.fromkeys(ids))
    if a.list_only:
        os.makedirs(a.out, exist_ok=True)
        p = os.path.join(a.out, "morgan_ids.txt")
        with open(p, "w", encoding="utf-8") as f:
            f.write("\n".join(ids))
        print(f"{len(ids)} manuscript IDs found. Saved to {p}")
        print("Review them, then run again without --list-only to download.")
        return
    print(f"{len(ids)} manuscript(s) to download -> {a.out}")
    ok = 0
    for k, mid in enumerate(ids, 1):
        print(f"[{k}/{len(ids)}] Morgan {mid}")
        try:
            ok += download(mid, "", a.out, a.pause)
        except KeyboardInterrupt:
            print("\nStopped. Run the same command again to continue."); sys.exit(1)
        except Exception as e:
            print(f"   ! skipped: {e}")
    print(f"Done: {ok}/{len(ids)} manuscripts complete.")


if __name__ == "__main__":
    main()
