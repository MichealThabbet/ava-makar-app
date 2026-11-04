"""Split the approved intro composite into two layers for the cinematic opening.

back : the approved composite (sharp sanctuary, arches, texture) with the saint removed
       (saint area filled by diffusion from its surroundings; only a thin edge ever shows).
saint: the owner's transparent St Macarius, colour-matched to the composite, with the
       bottom gradient of the approved composite (fade 62 % -> 80 % of its height).
Fit found by matching the saint into the composite: scale 0.56, top-left (194, 38) on 942 x 1670.

Usage: python3 intro_layers.py <composite.png> <saint.png> <out_dir>
"""
import sys
import numpy as np
from PIL import Image, ImageFilter

COMP, SAINT, OUT = sys.argv[1:4]
SC, X, Y = 0.56, 194, 38
comp = Image.open(COMP).convert('RGB')
W, H = comp.size
sa = Image.open(SAINT).convert('RGBA')
sw, sh = round(sa.width * SC), round(sa.height * SC)
small = sa.resize((sw, sh), Image.LANCZOS)
A = np.asarray(small).astype(float)

# colour match on the opaque upper half (face, beard, halo)
C = np.asarray(comp.crop((X, Y, X + sw, Y + sh))).astype(float)
m = A[..., 3] > 240; m[int(sh * .5):] = False
gain = (C[m].mean(0) + 1) / (A[..., :3][m].mean(0) + 1)
print('gain', gain.round(3))

# saint at full resolution, graded, with the bottom fade
S = np.asarray(sa).astype(float)
S[..., :3] = np.clip(S[..., :3] * gain, 0, 255)
yy = np.linspace(0, 1, sa.height)[:, None]
t = np.clip((yy - .62) / (.80 - .62), 0, 1); fade = 1 - t * t * (3 - 2 * t)
S[..., 3] *= fade
Image.fromarray(S.astype(np.uint8), 'RGBA').save(f'{OUT}/intro-saint.webp', 'WEBP', quality=92, method=6)

# background: remove the saint where it is opaque, fill by diffusion
core = np.zeros((H, W), bool)
af = A[..., 3] / 255 * np.asarray(Image.fromarray((fade[:, 0] * 255).astype(np.uint8)).resize((1, sh)))[:, :1] / 255
core[Y:Y + sh, X:X + sw] = af > .5
mask = Image.fromarray((core * 255).astype(np.uint8)).filter(ImageFilter.MaxFilter(31))
M = np.asarray(mask) > 0
img = np.asarray(comp).astype(float)
fill = img.copy(); known = ~M
fill[M] = 0
k = known.astype(float)
for r in [64, 32, 16, 8, 4, 2]:                      # multi-scale push-pull fill
    for _ in range(3):
        b = np.stack([np.asarray(Image.fromarray(fill[..., c].astype(np.uint8) if False else np.uint8(np.clip(fill[..., c], 0, 255))).filter(ImageFilter.BoxBlur(r)), float) for c in range(3)], -1)
        w = np.asarray(Image.fromarray(np.uint8(k * 255)).filter(ImageFilter.BoxBlur(r)), float) / 255
        est = b / np.maximum(w[..., None], 1e-3)
        fill = np.where(M[..., None], est * (w[..., None] > .02) + fill * (w[..., None] <= .02), img)
        k = np.maximum(k, (w > .02).astype(float))
soft = np.asarray(mask.filter(ImageFilter.GaussianBlur(12)), float)[..., None] / 255
back = img * (1 - soft) + np.clip(fill, 0, 255) * soft
Image.fromarray(back.astype(np.uint8)).save(f'{OUT}/intro-back.jpg', quality=92, optimize=True, progressive=True)
print('placement %', round(X / W * 100, 3), round(Y / H * 100, 3), round(sw / W * 100, 3))
