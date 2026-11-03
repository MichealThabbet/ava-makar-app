"""Aged paper sheets with torn, scorched edges and a baked soft shadow (RGBA PNG).

Run: python3 tools/textures/paper.py app/assets/textures
Procedural (fixed seeds); no photographs.
"""
import sys
import numpy as np
from PIL import Image, ImageFilter

OUT = sys.argv[1]
W, H, PAD = 520, 480, 34


def fbm1(n, seed, rough=0.55, octaves=6):
    rng = np.random.default_rng(seed)
    x = np.linspace(0, 1, n)
    out = np.zeros(n)
    amp, freq = 1.0, 4
    for _ in range(octaves):
        pts = rng.normal(size=freq + 1)
        out += amp * np.interp(x * freq, np.arange(freq + 1), pts)
        amp *= rough
        freq *= 2
    return out


def noise2(h, w, beta, seed):
    rng = np.random.default_rng(seed)
    fy = np.fft.fftfreq(h)[:, None]
    fx = np.fft.fftfreq(w)[None, :]
    f = np.sqrt(fx ** 2 + fy ** 2)
    f[0, 0] = 1
    a = np.real(np.fft.ifft2((rng.normal(size=(h, w)) + 1j * rng.normal(size=(h, w))) / f ** beta))
    return (a - a.min()) / (a.max() - a.min())


def sheet(seed):
    y, x = np.mgrid[0:H, 0:W].astype(float)
    # Torn edges: each side displaced by 1-D fractal noise (big waves + fine tears).
    top = PAD + 8 + 7 * fbm1(W, seed + 1) + 1.6 * fbm1(W, seed + 2, rough=0.7, octaves=8)
    bot = H - PAD - 16 - 7 * fbm1(W, seed + 3) - 1.6 * fbm1(W, seed + 4, rough=0.7, octaves=8)
    lef = PAD + 8 + 7 * fbm1(H, seed + 5) + 1.6 * fbm1(H, seed + 6, rough=0.7, octaves=8)
    rig = W - PAD - 8 - 7 * fbm1(H, seed + 7) - 1.6 * fbm1(H, seed + 8, rough=0.7, octaves=8)
    d = np.minimum.reduce([y - top[None, :], bot[None, :] - y, x - lef[:, None], rig[:, None] - x])
    mask = np.clip(d + 0.5, 0, 1)

    # Distance-like fields from the torn silhouette (blurred mask): smooth, follows the tear.
    m8 = Image.fromarray((mask * 255).astype(np.uint8))
    near = 1 - np.asarray(m8.filter(ImageFilter.GaussianBlur(7)), float) / 255
    mid = 1 - np.asarray(m8.filter(ImageFilter.GaussianBlur(22)), float) / 255
    far = 1 - np.asarray(m8.filter(ImageFilter.GaussianBlur(60)), float) / 255

    # Paper body: warm tan, mottling, tide-line stains, fibres and specks.
    mott = noise2(H, W, 1.7, seed + 10)
    stain = noise2(H, W, 2.3, seed + 11)
    fib = noise2(H, W, 0.25, seed + 12)
    rng = np.random.default_rng(seed + 13)
    specks = (rng.random((H, W)) > 0.9985).astype(float)
    specks = np.asarray(Image.fromarray((specks * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(0.8)), float) / 255
    tide = np.clip(1 - np.abs(stain - 0.68) * 18, 0, 1)  # thin darker rings around stains
    v = 0.66 + 0.26 * (mott - 0.5) + 0.10 * (fib - 0.5)
    v -= 0.20 * np.clip(stain - 0.66, 0, 1) * 4 + 0.10 * tide + 0.5 * specks
    # Scorched rim, then aged band, then a broad vignette.
    v -= 1.35 * near ** 1.3 + 0.38 * mid + 0.22 * far
    light = np.array([246, 214, 150], float)
    dark = np.array([84, 42, 12], float)
    v = np.clip(v, 0, 1)
    rgb = dark + (light - dark) * v[..., None]

    paper = Image.fromarray(np.dstack([rgb, mask * 255]).clip(0, 255).astype(np.uint8), 'RGBA')

    # Baked soft shadow (no frame): blurred silhouette, offset downwards.
    sh = Image.fromarray((mask * 120).astype(np.uint8)).filter(ImageFilter.GaussianBlur(11))
    shadow = Image.new('RGBA', (W, H), (20, 12, 8, 0))
    shadow.putalpha(sh)
    canvas = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    canvas.alpha_composite(shadow, (0, 9))
    canvas.alpha_composite(paper)
    return canvas


for i in range(3):
    sheet(100 + i * 50).save(f'{OUT}/paper_{i + 1}.png', optimize=True)
print('ok')
