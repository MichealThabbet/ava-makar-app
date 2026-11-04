# Home page design audit — 2026-11-04

Method: full-page capture at 390 px (2x), section by section; each point seen on screen.
Severity: A = breaks quality or correctness, B = weakens the luxury feel, C = polish.

## System (whole page)
1. A — No spacing grid: side gutters 12 / 18 / 22 px, section padding 26 / 34 / 46 px. Fix: 8-pt scale, one 20 px gutter, section rhythm 64 / 32.
2. A — No type scale: every element has its own clamp(). Fix: modular scale 1.25 (13 / 16 / 20 / 25 / 31 / 39 / 49).
3. A — Monotone: brown on brown on brown, sections blur together. Fix: alternate dark bands and ivory/paper bands; accents with roles (burgundy = liturgy, juniper = tour, gold = emphasis only).
4. B — Gold on everything (titles, buttons, icons, lines, labels): nothing stands out. Fix: gold for section titles and the one primary action per section.
5. A — Section headers inconsistent: gold titles (readings, news), ink titles inside cards (sayings), title inside card (guide), none (services). Fix: one header component: ornament, kicker, title.
6. B — Shadows: a different blur and offset per card. Fix: three elevation tokens.
7. C — Radii: 2 / 6 / 14 / 16 / pill. Fix: two radii (6, 18) and pill.
8. B — Motion: the same fade-up everywhere. Fix: one signature movement per section (unroll, page turn, slide-in rail, route draw).
9. B — Chrome: header 74 px + bottom bar 70 px = 17 % of the screen, always. Fix: slimmer header (60 px) that compacts on scroll.

## Header
10. B — Paper strip: rolled ends cut, title not optically centred (labels under icons have different widths).
11. B — Gold icons on mid-tan paper: low contrast (≈ 2.5 : 1).

## Hero (photo show)
12. A — Paper frame image stretched 100 % × 100 %: torn edges distorted, the curl squashed; uneven paper margins (8.5 % sides, 11 % bottom).
13. B — Portrait frame of 78 vh crops the photos hard (the gate shows half the facade).
14. B — Progress bar sits on the paper edge and reads as a glitch.
15. A — Hero fills ~90 % of the first screen: the daily readings (the core) are not visible without scrolling.

## Readings
16. A — Book image 1072 px wide: soft on 3x screens.
17. A — Text on the pages does not follow the pages (left page overruns the gutter) and is still ~11.5 px: decorative, not readable.
18. A — The drop cap breaks Arabic letter joining (ح + دث): typographic error. Applies to every drop cap on the page.
19. A — Lectern and candles drawn in CSS: flat and cheap next to a photographic book; candles taller than the book, holders oversized, wax too white.
20. B — Seven ribbons scroll sideways: «الكاثوليكون» cut at the edge looks like a bug; 3 of 7 hidden.
21. B — Active ribbon barely different from the others.
22. C — «اقرأ القراءة كاملة» repeats tapping the book.

## Sayings
23. A — Three cards, three container languages (scroll / leather + sheet / plain block): not one family.
24. A — The St Macarius scroll unrolls only through a scroll trigger; if it does not fire it stays a thin stick (seen in a capture).
25. B — Justified Arabic without kashida: wide word gaps; texts up to 900 characters with no «اقرأ المزيد».
26. B — Source line overlaps the curl of the Fr Matta sheet; Fr Matta portrait overlaps the sheet edge.
27. B — The Anba Epiphanius placeholder is a large empty block.
28. C — Vertical gold line behind the cards shows only in the gaps: reads as a stray stick.

## News
29. A — News photos in their raw colours (cyan studio background) clash with the palette. Fix: warm duotone.
30. B — Rail mixes a paper card and photo cards of different heights; no rail affordance (dots or arrows).
31. C — Warning title runs to three lines.

## Guide
32. B — Juniper card is half empty until the route draws; no image of the monastery.

## Services and releases
33. A — Retreat house title over a busy photo (iconostasis): poor legibility; a decorative corner from the photo shows at top left.
34. B — Donations and prayer requests have no icons, releases and products do: inconsistent.
35. B — Thin 1.5 px line icons clash with the 3-D gold language.
36. C — Two columns of ~160 px: titles near wrapping.

## Footer and bottom bar
37. B — Footer is plain text on flat brown: no mark, no texture, links not styled as links, «يُضاف» repeated.
38. C — Bottom-bar labels differ from the menu names (الصلوات / الصلوات والقراءات الكنسية).

## Performance
39. B — Many CSS drop-shadow filters and a fixed background: risk of jank on iPhone Safari. Fix: bake shadows into images, use box-shadow.
40. C — Fonts loaded as full variable TTF (Cairo ~600 KB): subset to Arabic and WOFF2.
