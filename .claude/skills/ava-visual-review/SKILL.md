---
name: ava-visual-review
description: Ruthless visual QA for Ava-Makar screens before showing anything to the owner — screenshots at 360/390/430/1440, overflow and console checks, a 40-point design checklist and three hostile review passes. Use before any visual delivery or claim that a screen is done.
---

# Visual review (do it before the owner sees it)

## 1. Capture
```bash
# serve the build or prototype locally first (python3 -m http.server in the build dir)
node tools/review/shots.js http://localhost:8765/<path>/ /tmp/claude-0/.../scratchpad/review 360,390,430,1440 8000
```
- Every line printed must show `errors: []` and `scrollW` equal to the width.
- Combine screenshots into one contact sheet (Pillow).
- Look at each section crop at 2x, and zoom 3x crops on edges, gold and text.

## 2. Checklist (fail one = fix before showing)
**Layout**
- One 8-pt grid, 20 px side gutter.
- Equal rhythm between sections; heading close to its section.
- Nothing cut at screen edges; no horizontal scroll.
- Safe areas respected (iPhone notch / home bar).

**Type**
- Headings in bold Ruqaa metallic gold.
- Body text bold enough, ≥ 13 px, text-shadow on dark.
- One type scale (1.25).
- No broken Arabic joining (no single-letter drop caps); tashkeel intact; RTL correct; Coptic in Noto Sans Coptic.

**Colour**
- Gold only for emphasis; no muddy band in the gold.
- Dark brown as the owner's reference.
- Light and dark cards alternate; contrast at least 4.5:1 for text.

**Images**
- Sharp at 3x; no fringe, halo, checkerboard or cut marks.
- No text over photo details; photos landscape where the owner said so; correct focus point.

**Components**
- Cards are one family with variety.
- Three shadow levels, two radii.
- Icons in one style (metallic gold, not thin lines).

**Motion**
- Slow, cinematic, one signature move per section.
- Reduced-motion fallback; no jank (transform/opacity only).

**Content**
- Only real content from data files; placeholders say «يُضاف»; nothing invented.
- Dates come from the calendar engine.

**Owner's explicit rules:** HANDOFF §7 — reread it each time.

## 3. Three hostile passes
1. **Engineer:** does it break at 360 or 1440, with long names, with missing data, with no network, in Safari?
2. **Art director:** proportions, hierarchy, balance, richness, originality. Would this win a luxury design award? If it looks like a template, redo it.
3. **The owner:** read HANDOFF §2 and §7, then hunt for what he would call «وحش / فقير / حمضان / ناقص». Fix all of it.

## 4. Report
- One combined screenshot.
- What was fixed in the review.
- What is still open, with the reason.
- Never say «done» while a checklist item fails.
