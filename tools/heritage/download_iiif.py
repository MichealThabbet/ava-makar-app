#!/usr/bin/env python3
"""Ava-Makar heritage downloader: saves manuscripts from IIIF libraries to a local disk.

Usage (Windows / macOS / Linux, Python 3.8+, no extra packages needed):
    python download_iiif.py CATALOG.json [CATALOG2.json ...] --out "E:/Coptic_Heritage" [--tier 1 2]
    python download_iiif.py CATALOG.json  --out D:/Heritage --only Vat.copt.57 Vat.copt.58
    python download_iiif.py CATALOG.json  --out D:/Heritage --width 2000   (smaller files)
    python download_iiif.py CATALOG.json  --out D:/Heritage --pdf          (also one PDF per manuscript; needs Pillow)

Safe to stop (Ctrl+C) and run again: pages already saved are skipped.
Layout:  OUT/<library>/<collection>/<shelfmark>/0001.jpg ...  + manifest.json + info.txt
Polite: one request at a time with a pause, retries on network errors.
Images remain under each library's copyright and terms; keep them for study and
archive, and ask the library before republishing.
"""
import argparse, json, os, shutil, sys, time, urllib.request, urllib.error

# Windows consoles may not print characters like ✓; never crash on output.
for _stream in (sys.stdout, sys.stderr):
    try:
        _stream.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

UA = "AvaMakar-Heritage/1.0 (monastery archive; polite downloader)"

# Use the operating system's certificate store (Windows/macOS) when available.
# Python's own bundle can fail on servers that do not send their full certificate
# chain (seen on Windows with digi.vatlib.it); the OS store completes the chain.
# Verification stays ON.
try:
    import truststore
    truststore.inject_into_ssl()
except ImportError:
    pass


def fetch(url, tries=5, timeout=90):
    last = None
    for i in range(tries):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": UA})
            with urllib.request.urlopen(req, timeout=timeout) as r:
                return r.read()
        except urllib.error.HTTPError as e:
            if e.code in (404, 403, 401):
                raise
            last = e
        except Exception as e:  # network hiccup
            last = e
        time.sleep(min(60, 3 * 2 ** i))
    raise last


def canvases(manifest):
    """Yield (label, image-service-or-url) for IIIF Presentation 2 and 3."""
    if "sequences" in manifest:  # v2
        for c in manifest["sequences"][0].get("canvases", []):
            res = c["images"][0]["resource"]
            svc = res.get("service")
            if isinstance(svc, list):
                svc = svc[0]
            yield c.get("label", ""), (svc.get("@id") if svc else None), res.get("@id")
    else:  # v3
        for c in manifest.get("items", []):
            body = c["items"][0]["items"][0]["body"]
            svc = body.get("service", [{}])
            svc = svc[0] if isinstance(svc, list) and svc else svc
            sid = svc.get("id") or svc.get("@id") if svc else None
            yield c.get("label", ""), sid, body.get("id")


def loc_manifest(d):
    """Turn a loc.gov ?fo=json record into a minimal IIIF v2 manifest (image services only)."""
    out = []
    for res in d.get("resources", []):
        for page in res.get("files", []):
            for f in page:
                u = f.get("url", "")
                if "/image-services/iiif/" in u and "/full/" in u:
                    svc = u.split("/full/")[0]
                    out.append({"label": str(len(out) + 1), "images": [{"resource": {"@id": svc + "/full/full/0/default.jpg", "service": {"@id": svc}}}]})
                    break
    return {"@context": "loc.gov json", "label": d.get("item", {}).get("title"), "sequences": [{"canvases": out}]}


def image_url(service, direct, width):
    if service:
        size = "full" if not width else f"{width},"
        return f"{service.rstrip('/')}/full/{size}/0/default.jpg"
    return direct


def safe(name):
    return "".join(ch if ch.isalnum() or ch in ".-_ " else "_" for ch in name).strip()


def download_one(item, out, width, pause, make_pdf):
    lib, sm = safe(item["library"]), safe(item["shelfmark"])
    name = sm
    if item.get("title") and item["library"] != "Vatican_BAV":
        name = (sm + " - " + safe(str(item["title"]))[:60]).strip(" .")
    folder = os.path.join(out, lib, safe(item.get("collection", "")), name)
    os.makedirs(folder, exist_ok=True)
    if item.get("file_url"):  # a single public-domain file (e.g. an archive.org PDF)
        dest = os.path.join(folder, safe(item.get("file_name") or os.path.basename(item["file_url"])))
        with open(os.path.join(folder, "info.txt"), "w", encoding="utf-8") as f:
            for k, v in item.items():
                if not k.startswith("_"):
                    f.write(f"{k}: {v}\n")
        want = int(item.get("size") or 0)
        if os.path.exists(dest) and (not want or os.path.getsize(dest) == want):
            print(f"   {sm}: already saved")
            return True
        data = fetch(item["file_url"], timeout=600)
        if want and len(data) != want:
            print(f"   ! {sm}: incomplete file ({len(data)} of {want} bytes), run again")
            return False
        with open(dest + ".part", "wb") as f:
            f.write(data)
        os.replace(dest + ".part", dest)
        print(f"   {sm}: {len(data) / 1e6:.1f} MB saved")
        time.sleep(pause)
        return True
    mpath = os.path.join(folder, "manifest.json")
    if os.path.exists(mpath):
        manifest = json.load(open(mpath, encoding="utf-8"))
    elif item.get("loc_json"):  # Library of Congress: JSON API (its manifest URL is bot-protected)
        manifest = loc_manifest(json.loads(fetch(item["loc_json"])))
        json.dump(manifest, open(mpath, "w", encoding="utf-8"), ensure_ascii=False)
    else:
        manifest = json.loads(fetch(item["manifest"]))
        json.dump(manifest, open(mpath, "w", encoding="utf-8"), ensure_ascii=False)
    pages = list(canvases(manifest))
    with open(os.path.join(folder, "info.txt"), "w", encoding="utf-8") as f:
        for k, v in item.items():
            f.write(f"{k}: {v}\n")
        f.write(f"pages: {len(pages)}\n")
    done = 0
    files = []
    for n, (label, svc, direct) in enumerate(pages, 1):
        dest = os.path.join(folder, f"{n:04d}.jpg")
        files.append(dest)
        if os.path.exists(dest) and os.path.getsize(dest) > 1000:
            done += 1
            continue
        try:
            data = fetch(image_url(svc, direct, width))
        except Exception as e:
            print(f"   ! page {n} failed: {e}")
            continue
        tmp = dest + ".part"
        with open(tmp, "wb") as f:
            f.write(data)
        os.replace(tmp, dest)
        done += 1
        print(f"\r   {sm}: {done}/{len(pages)} pages", end="", flush=True)
        time.sleep(pause)
    print(f"\r   {sm}: {done}/{len(pages)} pages" + (" ✓" if done == len(pages) else " (run again to finish)"))
    if make_pdf and done == len(pages):
        pdf = os.path.join(folder, f"{sm}.pdf")
        if not os.path.exists(pdf):
            try:
                from PIL import Image
                imgs = [Image.open(p).convert("RGB") for p in files]
                imgs[0].save(pdf, save_all=True, append_images=imgs[1:])
                print(f"   PDF saved: {pdf}")
            except ImportError:
                print("   (PDF skipped: install Pillow with  pip install pillow)")
    return done == len(pages)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("catalog", nargs="+", help="one or more catalog JSON files, downloaded one library after another")
    ap.add_argument("--out", required=True, help="destination folder, e.g. E:/Coptic_Heritage")
    ap.add_argument("--only", nargs="*", help="shelfmarks to download (default: all)")
    ap.add_argument("--tier", type=int, nargs="*", help="tiers to download, e.g. 1 2 (default: all)")
    ap.add_argument("--collection", nargs="*", help="collections to download, e.g. Vat.copt Borg.copt")
    ap.add_argument("--width", type=int, default=0, help="page width in px (default: full size)")
    ap.add_argument("--pause", type=float, default=1.0, help="seconds between pages (default 1)")
    ap.add_argument("--pdf", action="store_true", help="also make one PDF per manuscript")
    ap.add_argument("--reserve", type=float, default=5.0, help="GB to keep free on the disk (default 5)")
    a = ap.parse_args()
    items = []
    for ci, path in enumerate(a.catalog):
        data = json.load(open(path, encoding="utf-8"))
        if isinstance(data, dict):
            data = data["manuscripts"]
        for it in data:
            it["_cat"] = ci
        items += data
    if a.only:
        want = set(a.only)
        items = [i for i in items if i["shelfmark"] in want]
    if a.tier:
        items = [i for i in items if int(i.get("tier", 0)) in set(a.tier)]
    if a.collection:
        items = [i for i in items if i.get("collection") in set(a.collection)]
    items.sort(key=lambda i: (i["_cat"], i.get("tier", 0), i.get("order", 0), -int(i.get("priority", 0)), i["shelfmark"]))
    total = sum(int(i.get("pages", 0)) for i in items)
    print(f"{len(items)} manuscripts, about {total} pages -> {a.out}")
    ok = 0
    for k, item in enumerate(items, 1):
        os.makedirs(a.out, exist_ok=True)
        free_gb = shutil.disk_usage(a.out).free / 1e9
        need_gb = (int(item["size"]) / 1e9 if item.get("size") else int(item.get("pages", 0)) * 1.2 / 1000) + a.reserve
        if free_gb < need_gb:
            print(f"\nSTOP: disk almost full ({free_gb:.1f} GB free, about {need_gb:.1f} GB needed for "
                  f"{item['shelfmark']} plus {a.reserve} GB reserve).")
            print("Free some space or run again with --out on another disk.")
            break
        print(f"[{k}/{len(items)}] {item['library']} {item['shelfmark']}  {item.get('note', '')}")
        try:
            ok += download_one(item, a.out, a.width, a.pause, a.pdf)
        except KeyboardInterrupt:
            print("\nStopped. Run the same command again to continue.")
            sys.exit(1)
        except Exception as e:
            print(f"   ! skipped: {e}")
    print(f"Done: {ok}/{len(items)} manuscripts complete.")


if __name__ == "__main__":
    main()
