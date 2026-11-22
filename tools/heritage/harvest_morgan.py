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

# نصوص صفحة الحماية (Cloudflare وغيره)
CHALLENGE = re.compile(r"just a moment|verify you are human|checking your browser|"
                       r"cf-challenge|needs to review the security|attention required|"
                       r"enable javascript and cookies", re.I)

def wait_pass(pg, first=False):
    """يستنّى لحد ما صفحة الحماية تعدّي. أول مرة: بإيدك في النافذة. بعدها: أوتوماتيك."""
    waited = 0
    limit = 300 if first else 40   # أول مرة 5 دقايق تعدّي بإيدك، بعدها 40 ثانية
    while waited < limit:
        html = pg.content()
        if not CHALLENGE.search(html):
            return html
        if first and waited == 0:
            print("  ⚠ صفحة حماية — عدّي التأكيد في النافذة بإيدك. السكربت هيكمّل لوحده بعدها.")
        time.sleep(2); waited += 2
    return pg.content()

# روابط الصور اللي العارض بيطلبها بالـJavaScript (مش موجودة في كود الصفحة)
IMG_REQ = re.compile(r"ImageProperties\.xml|/TileGroup\d+/|zoomify|/iiif/|info\.json|\.dzi\b|_files/\d+/|"
                     r"/tiles?/|\.(?:jpe?g|tiff?|jp2|png)(?:\?|$)", re.I)
SKIP_IMG = re.compile(r"logo|icon|sprite|favicon|banner|header|footer|social|thumb(?:nail)?s?/|/styles/|"
                      r"google|facebook|twitter|doubleclick|analytics|cloudflare", re.I)
# صفحات تستاهل نزورها: صفحات مخطوطات/سجلات بس، مش أخبار وفعاليات ومحل
FOLLOW = re.compile(r"/manuscript/|/manuscripts?(?:/|$|\?)|/collection/[^/?#]+/\d+|/collection/[^/?#]+/?$|"
                    r"corsair\.themorgan\.org/.*(?:record|vwebv|holding|bib)", re.I)
NOFOLLOW = re.compile(r"/(?:events?|exhibitions?|programs?|calendar|news|press|shop|store|visit|membership|"
                      r"support|donate|about|education|blog|stories|search|login|user|cart)(?:/|$|\?)", re.I)

def zoom_base(u):
    if "ImageProperties.xml" in u:
        return u.split("?")[0]
    if re.search(r"/TileGroup\d+/", u):
        return re.split(r"/TileGroup\d+/", u)[0].rstrip("/") + "/ImageProperties.xml"
    return None

def open_ctx(pw):
    kw = dict(headless=os.environ.get("MORGAN_HEADLESS") == "1",   # للاختبار بس
              args=["--disable-blink-features=AutomationControlled"],
              ignore_default_args=["--enable-automation"])
    try:
        ctx = pw.chromium.launch_persistent_context(os.path.join(HERE, "morgan_profile"), channel="chrome", **kw)
    except Exception:
        ctx = pw.chromium.launch_persistent_context(os.path.join(HERE, "morgan_profile"), **kw)
    ctx.add_init_script("Object.defineProperty(navigator,'webdriver',{get:()=>undefined})")
    return ctx

def probe(url):
    """يفتح صفحة واحدة ويسجّل كل طلبات المتصفح — عشان نعرف نمط روابط الصور عند مورجان."""
    from playwright.sync_api import sync_playwright
    reqs = []
    with sync_playwright() as pw:
        ctx = open_ctx(pw)
        ctx.on("request", lambda r: reqs.append(f"{r.resource_type}\t{r.url}"))
        pg = ctx.pages[0] if ctx.pages else ctx.new_page()
        pg.goto(url, wait_until="domcontentloaded", timeout=90000)
        wait_pass(pg, first=True)
        print("  الصفحة فتحت. لو فيه صورة مخطوط، اضغط عليها أو على زرار التكبير (zoom) دلوقتي...")
        for _ in range(6):
            pg.mouse.wheel(0, 1500); time.sleep(5)
        pg.screenshot(path=os.path.join(HERE, "morgan_probe.png"), full_page=True)
        open(os.path.join(HERE, "morgan_probe.html"), "w", encoding="utf-8").write(pg.content())
        open(os.path.join(HERE, "morgan_probe_requests.txt"), "w", encoding="utf-8").write("\n".join(reqs))
        ctx.close()
    imgs = [r for r in reqs if IMG_REQ.search(r) and not SKIP_IMG.search(r)]
    print(f"\nاتسجل {len(reqs)} طلب، منهم {len(imgs)} شكلهم صور. أمثلة:")
    for r in imgs[:15]:
        print("   ", r[:160])
    print("\nابعت الـ3 ملفات: morgan_probe_requests.txt و morgan_probe.html و morgan_probe.png")

def run(seeds):
    from playwright.sync_api import sync_playwright
    zoom, seen_pg, found = [], set(), set()
    queue = [s for s in seeds if host_ok(s)]
    queued = set(queue)
    first_page = True
    other_imgs = []
    with sync_playwright() as pw:
        # سياق دائم (الكوكيز تتحفظ) + Chrome الحقيقي + إخفاء علامة الأتمتة
        ctx = open_ctx(pw)
        page_imgs = []
        ctx.on("request", lambda r: page_imgs.append(r.url) if IMG_REQ.search(r.url) and not SKIP_IMG.search(r.url) else None)
        pg = ctx.pages[0] if ctx.pages else ctx.new_page()
        b = ctx
        while queue and len(seen_pg) < MAX:
            u = queue.pop(0)
            if u in seen_pg: continue
            seen_pg.add(u)
            page_imgs.clear()
            try:
                pg.goto(u, wait_until="domcontentloaded", timeout=90000); time.sleep(1.0)
                html = wait_pass(pg, first=first_page)
                first_page = False
                time.sleep(3)   # نسيب العارض يطلب الصور
            except Exception as e:
                print("  خطأ:", repr(e)[:50]); continue
            # الصور من الكود + من طلبات المتصفح
            cands = find_zoomify(html) + [zb for zb in (zoom_base(x) for x in page_imgs) if zb]
            for z in cands:
                if z not in found:
                    found.add(z); zoom.append(z)
            for x in page_imgs:
                if not zoom_base(x) and x not in other_imgs:
                    other_imgs.append(x)
            # زوّد صفحات المخطوطات بس للطابور
            for l in links_in(html, u):
                if l not in queued and FOLLOW.search(l) and not NOFOLLOW.search(l):
                    queued.add(l); queue.append(l)
            if len(seen_pg) % 10 == 0 or not queue:
                open(OUT, "w", encoding="utf-8").write("\n".join(zoom))
                open(os.path.join(HERE, "morgan_other_images.txt"), "w", encoding="utf-8").write("\n".join(other_imgs))
                print(f"  صفحات={len(seen_pg)}  طابور={len(queue)}  Zoomify={len(zoom)}  صور تانية={len(other_imgs)}")
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
    if "--probe" in sys.argv:
        if not a:
            print('حط رابط صفحة مخطوط واحدة:  python harvest_morgan.py --probe "https://www.themorgan.org/manuscript/..."')
            sys.exit(1)
        probe(a[0]); sys.exit(0)
    if not a:
        print("مفيش روابط → بستخدم نقاط البداية الافتراضية وأزحف منها لكل الموقع.")
        a = DEFAULT_SEEDS
    run(a)
