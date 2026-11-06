"""Remove the red/yellow/grey glow halo around owner's gold lettering or objects (RGBA in, RGBA out).

Keeps solid, saturated pixels (the metal), drops low-alpha or desaturated fringe, softens the edge by ~1 px.
Usage: python3 -I tools/assets/clean_halo.py <in.png> <out.webp|png> [--alpha 170] [--sat 40]
Check the result on the dark cross background before using it (see ava-asset-prep).
"""
import sys
import numpy as np
from PIL import Image, ImageFilter

src, dst = sys.argv[1], sys.argv[2]
args = dict(zip(sys.argv[3::2], sys.argv[4::2]))
A_MIN, S_MIN = int(args.get('--alpha', 170)), int(args.get('--sat', 40))
im = Image.open(src).convert('RGBA')
a = np.asarray(im).astype(float)
sat = a[..., :3].max(2) - a[..., :3].min(2)
keep = (a[..., 3] > A_MIN) & (sat > S_MIN)
m = Image.fromarray((keep * 255).astype(np.uint8)).filter(ImageFilter.MedianFilter(5)).filter(ImageFilter.MaxFilter(3)).filter(ImageFilter.GaussianBlur(.9))
a[..., 3] = np.minimum(a[..., 3], np.asarray(m, float))
out = Image.fromarray(a.astype(np.uint8), 'RGBA')
out = out.crop(out.getbbox())
if dst.endswith('.webp'):
    out.save(dst, 'WEBP', quality=94, method=6)
else:
    out.save(dst, optimize=True)
print(dst, out.size)
