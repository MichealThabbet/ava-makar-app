"""Prepare images for the home-page design prototype (owner's files, 2026-11-03).

- Monastery photos: resized, light colour grade, JPEG.
- Paper / book references on white: background removed, grey drop shadow
  converted to a real transparent shadow (RGBA PNG/WebP).
- Leather swatches cropped from the owner's reference boards (text-free areas).
- Portraits for news and sayings.

Usage: python3 tools/prototype/prep_assets.py <uploads_dir> <matta_assets_dir> <out_img_dir>
"""
import sys
import numpy as np
from PIL import Image, ImageFilter, ImageEnhance

UP, MATTA, OUT = sys.argv[1], sys.argv[2], sys.argv[3]


def up(name):
    return Image.open(f'{UP}/{name}').convert('RGB')


def save_jpg(im, name, w, q=80):
    if im.width > w:
        im = im.resize((w, round(im.height * w / im.width)), Image.LANCZOS)
    im.save(f'{OUT}/{name}', quality=q, optimize=True, progressive=True)


def grade(im):
    # Warm, slightly deeper blacks; no heavy filter.
    im = ImageEnhance.Contrast(im).enhance(1.06)
    im = ImageEnhance.Color(im).enhance(1.04)
    return im


# Monastery photos (hero slideshow), in showing order.
photos = [
    ('f405adc1-image.png', 'm1.jpg', (0, 0, 1, 0.80)),   # gate at sunset; crop off the car park
    ('6a10f22f-image.png', 'm2.jpg', None),               # ancient church nave
    ('2e7dbfd3-image.png', 'm3.jpg', None),               # lectern and iconostasis
    ('771975ef-image.png', 'm4.jpg', None),               # sanctuary screen, frontal
    ('b8f85fd3-image.png', 'm5.jpg', None),               # relics
    ('9a313cb7-image.png', 'm6.jpg', None),               # wide hall
    ('f3001817-image.png', 'm7.jpg', None),               # nave with bench
]
for src, dst, crop in photos:
    im = up(src)
    if crop:
        x0, y0, x1, y1 = crop
        im = im.crop((int(x0 * im.width), int(y0 * im.height), int(x1 * im.width), int(y1 * im.height)))
    save_jpg(grade(im), dst, 1600)  # never upscaled; keeps the owner's full resolution


def cutout(src, dst, w):
    im = up(src)
    if im.width > w:
        im = im.resize((w, round(im.height * w / im.width)), Image.LANCZOS)
    a = np.asarray(im).astype(float)
    sat = a.max(2) - a.min(2)
    lum = a.mean(2)
    paper = np.clip((sat - 14) / 14, 0, 1)            # beige paper / leather are saturated
    paper = np.asarray(Image.fromarray((paper * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(0.8)), float) / 255
    shadow = np.clip((248 - lum) / 110, 0, 1) * 0.75  # grey shadow on white -> black alpha
    alpha = np.maximum(paper, shadow * (1 - paper))
    rgb = a * paper[..., None] + np.array([18, 10, 6]) * (1 - paper[..., None])
    out = np.dstack([rgb, alpha * 255]).clip(0, 255).astype(np.uint8)
    img = Image.fromarray(out, 'RGBA')
    img = img.crop(img.getbbox())
    img.save(f'{OUT}/{dst}', 'WEBP', quality=86, method=6)


cutout('3ed8895b-image.jpg', 'book.webp', 1400)
cutout('8deda201-image.jpg', 'scroll.webp', 900)
cutout('aa3d7b79-image.jpg', 'sheet-curl.webp', 800)
cutout('b6d7aa53-image.jpg', 'sheet-wide.webp', 900)

# Leather swatches (text-free bands of the reference boards).
lea = [
    ('00e88fed-image.jpg', 'leather-chocolate.jpg', (0.02, 0.27, 0.98, 0.45)),
    ('00e88fed-image.jpg', 'leather-buttercream.jpg', (0.02, 0.50, 0.98, 0.66)),
    ('6eaeadc1-image.png', 'leather-juniper.jpg', (0.02, 0.15, 0.98, 0.245)),
    ('6eaeadc1-image.png', 'leather-toffee.jpg', (0.02, 0.27, 0.98, 0.37)),
    ('6eaeadc1-image.png', 'leather-alabaster.jpg', (0.02, 0.53, 0.98, 0.62)),
    ('0791dcf4-image.png', 'leather-cocoa.jpg', (0.03, 0.22, 0.97, 0.37)),
]
for src, dst, (x0, y0, x1, y1) in lea:
    im = up(src)
    im = im.crop((int(x0 * im.width), int(y0 * im.height), int(x1 * im.width), int(y1 * im.height)))
    save_jpg(im, dst, 900, q=82)

# Portraits.
def portrait(im, dst, w=420):
    save_jpg(im, dst, w, q=84)

portrait(up('7b67dee5-image.jpg'), 'news-demetri.jpg')
portrait(up('de7db839-image.jpg'), 'news-demetri-late.jpg')
portrait(up('e2ab5967-image.png'), 'news-said-hakim.jpg')
for i, f in enumerate(['88afdef0-image.png', '47074cdb-image.png', '25f9fe76-image.png'], 1):
    save_jpg(up(f), f'fake-{i}.jpg', 900, q=80)
portrait(Image.open(f'{MATTA}/aqwal.jpg').convert('RGB'), 'matta.jpg', 360)
print('ok')
