"""Procedural, tileable material textures for Ava-Makar (no photographs).

Run: python3 tools/textures/generate.py app/assets/textures
Fixed seeds, so output is reproducible. All textures tile seamlessly
(FFT-filtered noise is periodic).
"""
import sys
import numpy as np
from PIL import Image

OUT = sys.argv[1]


def noise(n, m, beta, seed, aniso=1.0):
    """Periodic 1/f^beta noise in [0,1]; aniso>1 stretches features along x."""
    rng = np.random.default_rng(seed)
    fy = np.fft.fftfreq(n)[:, None]
    fx = np.fft.fftfreq(m)[None, :] * aniso
    f = np.sqrt(fx ** 2 + fy ** 2)
    f[0, 0] = 1
    spec = (rng.normal(size=(n, m)) + 1j * rng.normal(size=(n, m))) / f ** beta
    spec[0, 0] = 0
    a = np.real(np.fft.ifft2(spec))
    return (a - a.min()) / (a.max() - a.min())


def save(arr, name, q=84):
    Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8)).save(f'{OUT}/{name}', quality=q, optimize=True)


def tint(v, dark, light):
    dark, light = np.array(dark, float), np.array(light, float)
    return dark + (light - dark) * v[..., None]


# Leather: tonal variation + pebbled grain + fine creases.
N = 512
base = noise(N, N, 1.6, 1)
pebble = noise(N, N, 0.9, 2)
ridge = 1 - np.abs(noise(N, N, 1.2, 3) * 2 - 1)
fine = noise(N, N, 0.3, 4)
v = 0.45 * base + 0.25 * pebble + 0.12 * fine - 0.22 * (ridge ** 6)
v = (v - v.min()) / (v.max() - v.min())
save(tint(v, (44, 24, 18), (112, 72, 54)), 'leather.jpg')

# Walnut: long grain along x, growth bands, pores.
M = 1024
g = noise(M, M, 1.7, 5, aniso=8)
bands = 0.5 + 0.5 * np.sin(g * 38)
pores = noise(M, M, 0.4, 6, aniso=6)
v = 0.55 * g + 0.30 * bands + 0.15 * pores
v = (v - v.min()) / (v.max() - v.min())
save(tint(v ** 1.3, (22, 14, 10), (78, 52, 36)), 'walnut.jpg')

# Sandstone: warm stone with ashlar courses (generic masonry, not a depiction of any building).
s = 0.6 * noise(M, M, 1.5, 7) + 0.3 * noise(M, M, 0.8, 8) + 0.1 * noise(M, M, 0.2, 9)
y = np.arange(M)[:, None]
x = np.arange(M)[None, :]
course = 128
row = y // course
joint_h = (y % course) < 3
joint_v = ((x + (row % 2) * 96) % 192) < 3
s = s - 0.18 * (joint_h | joint_v)
s = (s - s.min()) / (s.max() - s.min())
save(tint(s, (92, 70, 50), (196, 166, 128)), 'sandstone.jpg')

# Parchment: calm ivory with faint fibres and soft mottling (low contrast for reading).
p = 0.7 * noise(N, N, 1.8, 10) + 0.3 * noise(N, N, 0.6, 11, aniso=3)
p = (p - p.min()) / (p.max() - p.min())
save(tint(p, (228, 214, 188), (244, 236, 220)), 'parchment.jpg')
print('ok')
