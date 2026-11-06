---
name: ava-luxury-gold
description: Real metallic gold lettering and ornaments for Ava-Makar (bold Ruqaa headings, monastery name, gold buttons/icons) with bevel, moving specular light, extrusion and shadow. Use for any gold title, section heading, name, CTA or gold icon on web (HTML/SVG/CSS) or Flutter.
---

# Metallic gold (approved look: the header name, 2026-11-04)

The owner rejects: flat or dull gold, a dark-brown band through the middle of the letters, thin or non-bold Ruqaa, no shadow, gold everywhere.
Gold is for headings and the one primary action per section — not for body text, small labels and lines everywhere.

## Web — SVG text (crisp at any density; animated light)
```html
<svg class="gold-title" viewBox="0 0 320 64" role="img" aria-label="TITLE">
  <defs>
    <linearGradient id="g-gold" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#fffbe6"/><stop offset=".18" stop-color="#ffe9a3"/><stop offset=".42" stop-color="#f2c14e"/>
      <stop offset=".58" stop-color="#b9821f"/><stop offset=".74" stop-color="#f7d37a"/><stop offset="1" stop-color="#fff0bd"/>
    </linearGradient>
    <filter id="g-metal" x="-10%" y="-30%" width="120%" height="170%" color-interpolation-filters="sRGB">
      <feGaussianBlur in="SourceAlpha" stdDeviation="1.1" result="b"/>
      <feSpecularLighting in="b" surfaceScale="3.2" specularConstant="1.25" specularExponent="28" lighting-color="#fffaf0" result="sp">
        <feDistantLight class="g-light" azimuth="225" elevation="50"/>
      </feSpecularLighting>
      <feComposite in="sp" in2="SourceAlpha" operator="in" result="spIn"/>
      <feComposite in="SourceGraphic" in2="spIn" operator="arithmetic" k1="0" k2="1" k3="1" k4="0" result="lit"/>
      <feFlood flood-color="#4a2504" result="ex"/><feComposite in="ex" in2="SourceAlpha" operator="in" result="exA"/>
      <feOffset in="exA" dy="1" result="e1"/><feOffset in="exA" dy="2" result="e2"/>
      <feFlood flood-color="#000" flood-opacity=".8" result="sh"/><feComposite in="sh" in2="SourceAlpha" operator="in" result="shA"/>
      <feGaussianBlur in="shA" stdDeviation="2.2" result="shB"/><feOffset in="shB" dy="3.5" result="shadow"/>
      <feMerge><feMergeNode in="shadow"/><feMergeNode in="e2"/><feMergeNode in="e1"/><feMergeNode in="lit"/></feMerge>
    </filter>
  </defs>
  <text x="160" y="44" text-anchor="middle" direction="rtl" font-family="Ruqaa" font-weight="700" font-size="40"
        fill="url(#g-gold)" filter="url(#g-metal)">TITLE</text>
</svg>
```
```js
// slow moving light (respect reduced motion)
if (!matchMedia('(prefers-reduced-motion: reduce)').matches)
  gsap.fromTo('.g-light', { attr: { azimuth: 160 } }, { attr: { azimuth: 330 }, duration: 6, ease: 'sine.inOut', yoyo: true, repeat: -1 });
```
- Font: `@font-face { font-family: Ruqaa; src: url(fonts/ArefRuqaa-Bold.ttf); font-weight: 700; font-display: block; }`. Preload it, or the SVG text renders in a fallback font first.
- Use unique ids per SVG (`g-gold-1`, …) when there are several on a page, or put the `<defs>` once in a hidden SVG.
- Scale the text by the SVG width (`width: min(64vw, 300px)`), never by font-size in CSS.

## Web — CSS gold (for long or dynamic text where SVG is impractical)
`background: linear-gradient(180deg,#fff6cf 0%,#ffe08a 28%,#f6c544 55%,#e2a724 80%,#f8d36a 100%); -webkit-background-clip:text; background-clip:text; color:transparent; filter: drop-shadow(0 1.5px 0 #2e1503) drop-shadow(0 3px 4px rgba(0,0,0,.85));`
No dark stop in the middle. Fewer `drop-shadow` filters on iPhone Safari (cost).

## Image gold (owner's PNG names and titles)
Always clean the halo first (`ava-asset-prep`). Add movement with a masked sheen:
`.line::after { mask: var(--m) center/100% 100%; background: linear-gradient(105deg,transparent 38%,rgba(255,250,225,.95) 50%,transparent 62%) 160% 0/260% 100%; mix-blend-mode: screen; }`, then animate background-position once.

## Section heading on old paper (owner's rule)
Heading sits on a small old-paper scroll (`design-kit/05_paper_leather_references/section-title-scroll.webp`), sized to the heading (not page width), low height, close to the previous section; gold Ruqaa text on it, darkened paper so gold reads.

## Flutter
Use `ShaderMask` with the same gradient stops over bold Ruqaa `Text`, two `Shadow`s (1.5 px dark edge, 4 px blur) and a slow `AnimationController` moving a white highlight gradient (`GradientRotation` / `Alignment` tween). For headings that must look exactly like the web, render the SVG with `flutter_svg` or ship pre-rendered WebP at 3x.

## Check
Zoom the screenshot at 3x: crisp edges, gold readable on the background, no grey/brown band, shadow visible, motion slow.
