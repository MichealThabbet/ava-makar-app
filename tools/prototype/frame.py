"""Landscape old-paper frame for the photo show.

Texture: the owner's old scroll (clean interior area only, no cut edges), mirrored
to fill. Edges: procedural torn + scorched mask with a smooth alpha (no halos),
plus a baked soft shadow. Usage: python3 frame.py <owner_scroll.png> <out.webp>
"""
import sys
import numpy as np
from PIL import Image, ImageFilter, ImageOps

SRC, OUT = sys.argv[1], sys.argv[2]
W, H, PAD = 1600, 1220, 46


def fbm1(n, seed, rough=0.6, octaves=7):
    rng = np.random.default_rng(seed)
    x = np.linspace(0, 1, n); out = np.zeros(n); amp, f = 1.0, 5
    for _ in range(octaves):
        pts = rng.normal(size=f + 1); out += amp * np.interp(x * f, np.arange(f + 1), pts); amp *= rough; f *= 2
    return out


src = Image.open(SRC).convert('RGB')
tile = src.crop((330, 190, 1720, 590))                       # clean interior paper
row = Image.new('RGB', (tile.width * 2, tile.height)); row.paste(tile, (0, 0)); row.paste(ImageOps.mirror(tile), (tile.width, 0))
blk = Image.new('RGB', (row.width, row.height * 2)); blk.paste(row, (0, 0)); blk.paste(ImageOps.flip(row), (0, row.height))
paper = blk.resize((W, H), Image.LANCZOS)
a = np.asarray(paper).astype(float) * 0.82                   # a little deeper

y, x = np.mgrid[0:H, 0:W].astype(float)
top = PAD + 10 * fbm1(W, 1) + 3 * fbm1(W, 2, .8, 9)
bot = H - PAD - 14 - 10 * fbm1(W, 3) - 3 * fbm1(W, 4, .8, 9)
lef = PAD + 10 * fbm1(H, 5) + 3 * fbm1(H, 6, .8, 9)
rig = W - PAD - 10 * fbm1(H, 7) - 3 * fbm1(H, 8, .8, 9)
d = np.minimum.reduce([y - top[None], bot[None] - y, x - lef[:, None], rig[:, None] - x])
mask = np.clip(d / 1.6 + .5, 0, 1)                            # anti-aliased edge, no fringe
m8 = Image.fromarray((mask * 255).astype(np.uint8))
near = 1 - np.asarray(m8.filter(ImageFilter.GaussianBlur(9)), float) / 255
mid = 1 - np.asarray(m8.filter(ImageFilter.GaussianBlur(34)), float) / 255
shade = 1 - (1.25 * near ** 1.2 + .35 * mid)
rgb = np.clip(a * np.clip(shade, .12, 1)[..., None], 0, 255)
sheet = Image.fromarray(np.dstack([rgb, mask * 255]).astype(np.uint8), 'RGBA')
sh = m8.filter(ImageFilter.GaussianBlur(16)).point(lambda v: int(v * .7))
shadow = Image.new('RGBA', (W, H), (12, 5, 1, 0)); shadow.putalpha(sh)
canvas = Image.new('RGBA', (W, H), (0, 0, 0, 0)); canvas.alpha_composite(shadow, (0, 14)); canvas.alpha_composite(sheet)
canvas.save(OUT, 'WEBP', quality=90, method=6)
print('ok', canvas.size)
