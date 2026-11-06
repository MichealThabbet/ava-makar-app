---
name: ava-cinematic-motion
description: Calm cinematic motion and effects for Ava-Makar — layered intro with parallax, Ken Burns photo show, staggered fade/zoom titles, page turning, candle flames and church light, scroll reveals with GSAP/ScrollTrigger, Canvas and WebGL. Use for any animation, transition or visual effect, web or Flutter.
---

# Cinematic motion

## Principles (owner's rules)
- Cinematic and **slow**. Never quick or bouncy.
- Each section has its **own signature move** — not the same fade-up everywhere.
- Everything stops under `prefers-reduced-motion: reduce` (show the final state).
- Cheap on iPhone Safari:
  - animate only `transform` and `opacity`;
  - few `filter` effects;
  - no animated `blur` on large layers;
  - bake shadows and glows into images;
  - `will-change` only on moving layers;
  - canvas sized at most 2x devicePixelRatio.
- Skippable intro (tap = `timeline.progress(1)`).
- Never trap the user; total intro about 6–7 s.

## Library
GSAP 3.12.5 + ScrollTrigger, vendored in `app/web/prototype/vendor/`. Standard no-charge licence (see NOTICE). No CDN at runtime.

## Recipes
### 1. Layered intro (St Macarius over the sanctuary)
- **Layers:** `intro-back.jpg` (942×1670) behind, `intro-saint.webp` in front.
  - Saint placement (% of the back): left 20.594, top 2.275, width 60.828.
  - The gradient at the saint's bottom is already baked in (fade 62 % → 80 % of his height).
- **Depth:** back scales 1.10→1.00 over ~7 s; saint scales 1.06→1.00 and moves y −1.5 % → 0 over the same time.
  - Different speeds = parallax.
  - Optional: a pointer/gyro offset of ±6 px on the saint only.
- **Halo:** an absolutely positioned radial gradient over the halo centre, opacity 0.15 ↔ 0.85, `yoyo`, about 2 s.
- **Lamps:** small radial glows at lamp positions with random flicker (opacity .7–1, 80–220 ms tweens, `onComplete` recursion).
- **Incense:** an SVG `feTurbulence` + `feDisplacementMap` smoke layer, opacity .15, slowly drifting; or a Canvas particle smoke.
- **Name:** three cleaned line images, staggered 0.5 s.
  - Animate from opacity 0, scale 1.25, blur(6px) → 1, 1, 0 over 1.4 s, `power2.out`.
  - Then the masked sheen (see `ava-luxury-gold`).
- **Exit:** whole intro opacity → 0, scale → 1.08 over 1.3 s (`power2.inOut`); remove the node; start the page animations.

### 2. Ken Burns photo show (landscape, inside the clean paper frame)
- Per photo: `object-position: var(--focus)` (keep crosses and arches).
- Moves alternate push-in and pull-out with a 2–3 % pan; hold 6.5 s, crossfade 1.6 s, `sine.inOut`.
- Optional subtle film grain via an SVG noise data-URI at opacity .1.
- Thin progress bars inside the photo window.

### 3. Book on the lectern
- Page turn: one leaf element rotating `rotateY` 0 → −180° around the gutter.
  - **Better (planned):** WebGL page curl (Three.js plane with a vertex bend) or a CSS 3D two-half leaf with shading gradients.
- Candle flame: CSS/SVG flame with random `scaleY/scaleX/skewX` flicker.
  - Its warm light: a `mix-blend-mode: screen` radial gradient over the pages whose opacity follows the flame.

### 4. Scroll reveals (choose per section)
- **Scroll unroll** (scaleX .12 → 1). Use `ScrollTrigger.create({ once:true, start:'top bottom', onEnter })` so it can never stay collapsed.
- **Wax seal stamp** (scale 2.2 → 1, rotate −30 → −8, `back.out(2)`).
- **Gold route drawing** (`strokeDashoffset`).
- **Rail slide-in** for news.
- Parallax of the hero photos (`yPercent: 8`, `scrub`).

### 5. Church ambience over the fixed background
- **Rays:** repeating-linear-gradient at ~104°, screen blend, opacity .16, masked to the top half, 26 s drift.
- **Light pools:** two breathing radial gradients.
- **Dust:** a Canvas of about 34 motes rising slowly, alpha .15–.5.
- Disable all three under reduced motion.

## Flutter port
- `AnimationController` + `CurvedAnimation` (`Curves.easeOutCubic`, `easeInOutSine`).
- Parallax with `Transform`.
- Shimmer with a `ShaderMask` gradient sweep.
- Flame with `CustomPainter`.
- Dust with `CustomPainter` + `Ticker`.
- Lottie or Rive for complex loops, made from the owner's art only.
- Respect `MediaQuery.disableAnimations`.

## Check
- Record the intro: screenshots at 1 s, 3 s, 5 s, 7 s.
- Confirm the timing with `document.getElementById('intro')` presence.
- Confirm no console errors.
- Confirm `scrollWidth == innerWidth`.
