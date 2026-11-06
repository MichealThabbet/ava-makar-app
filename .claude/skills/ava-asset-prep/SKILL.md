---
name: ava-asset-prep
description: Prepare the owner's images for Ava-Makar — clean red/yellow glow halos and cut-out fringes, remove baked checkerboards, cut paper/book from white backgrounds, build clean torn-paper frames, split and colour-match layered art, keep full resolution. Use whenever an image from the owner enters the project.
---

# Asset preparation

The owner rejects:
- pixelated images;
- visible cut marks;
- white or grey fringes;
- the red/yellow speckled glow that his AI-made PNGs carry;
- stretched or distorted art.

## Always
- Work on copies, inside the scratchpad, with `python3 -I` (Pillow + NumPy).
- Never upscale beyond the source. Target 3x for phones: an element shown 390 px wide needs about 1170 px.
- Compare every result on the real background: `design-kit/01_backgrounds/background-coptic-crosses.jpg`. Zoom crops at 1:1 and check edges.
- Formats:
  - WebP q90–95 (alpha allowed) for art;
  - JPEG q85–93 for photos;
  - never PNG over 1 MB in the web build.
- Add `?v=N` to changed asset URLs (phones cache).

## Tools in the repo
| Need | Command / file |
|---|---|
| Glow halo around gold letters or objects | `python3 -I tools/assets/clean_halo.py in.png out.webp [--alpha 170] [--sat 40]` |
| Split a multi-line name into lines | `python3 -I tools/assets/split_lines.py clean.png out_prefix 3` (components grouped by line, dots and tashkeel kept) |
| Paper / book on white background → alpha | saturation mask + grey shadow → black alpha (`tools/prototype/prep_assets.py`, `cutout()`) |
| Clean torn landscape paper frame | `tools/prototype/frame.py <owner_scroll.png> out.webp` (texture from the clean interior, procedural torn and scorched edge, smooth alpha, baked shadow) |
| Saint over sanctuary layers | `tools/prototype/intro_layers.py <approved_composite> <saint.png> <out>` (fit, colour match, bottom fade, diffusion fill behind) |
| Baked grey checkerboard (fake transparency) | mask `sat > 28` + median filter (see `header-scroll` in HANDOFF) |
| Darken or warm a paper to sit on the dark ground | multiply by about .5–.6, warm toward brown, light centre vignette; test 3 variants in the real page and show them |

## Placement accuracy
To place a layer exactly as in an approved composite:
- search scale and position by normalised correlation on the opaque upper part;
- refine by mean pixel error;
- show the overlay difference before using it.

## Never
- Generate religious images or icons.
- Replace the owner's image with a similar one.
- Crop faces or stretch icons.
