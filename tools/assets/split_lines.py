"""Split a multi-line lettering image (e.g. the owner's 3-line gold name) into one image per line.

Groups connected components (letters, dots, diacritics) by their vertical centroid between the emptiest
row bands, so dots and tashkeel stay with their line. Run clean_halo.py first.
Usage: python3 -I tools/assets/split_lines.py <clean.png|webp> <out_prefix> [lines=3]
Writes <out_prefix>-l1.webp … ; check each on the dark background.
"""
import sys
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

src, prefix = sys.argv[1], sys.argv[2]
n_lines = int(sys.argv[3]) if len(sys.argv) > 3 else 3
im = Image.open(src).convert('RGBA'); im = im.crop(im.getbbox())
A = np.asarray(im).astype(float); core = A[..., 3] > 120
rows = core.sum(1); H = len(rows)
cuts = []
for k in range(1, n_lines):
    lo, hi = int(H * (k / n_lines - .18)), int(H * (k / n_lines + .18))
    cuts.append(lo + int(rows[lo:hi].argmin()))
work = Image.fromarray(np.where(core, 255, 0).astype(np.uint8)); lab = np.zeros(core.shape, np.int32); n = 0
while True:
    w = np.asarray(work); ys, xs = np.nonzero(w == 255)
    if len(ys) == 0: break
    n += 1; ImageDraw.floodfill(work, (int(xs[0]), int(ys[0])), 128)
    sel = np.asarray(work) == 128; lab[sel] = n; work.paste(0, mask=Image.fromarray((sel * 255).astype(np.uint8)))
line = np.zeros(core.shape, np.int8)
for i in range(1, n + 1):
    ys_i = np.nonzero(lab == i)[0]
    if len(ys_i) == 0: continue
    cy = ys_i.mean()
    line[lab == i] = 1 + sum(cy >= c for c in cuts)
for li in range(1, n_lines + 1):
    m = Image.fromarray(((line == li) * 255).astype(np.uint8)).filter(ImageFilter.MaxFilter(5))
    B = A.copy(); B[..., 3] = np.minimum(B[..., 3], np.asarray(m, float))
    p = Image.fromarray(B.astype(np.uint8), 'RGBA'); p = p.crop(p.getbbox())
    p.save(f'{prefix}-l{li}.webp', 'WEBP', quality=95, method=6); print(f'{prefix}-l{li}.webp', p.size)
