# Design direction — «Old Coptic Luxury»
Status: approved direction by the owner (2026-11-01, DEC-P0-21). Visual concepts to follow for selection.

## Principle
An app that feels like opening an illuminated Coptic manuscript inside a 4th-century desert monastery: ancient, monastic, quiet, and crafted with museum-level care. Luxury through material, proportion and restraint, never through decoration for its own sake.

## Sources of the language (inspiration, not copying)
- Coptic manuscripts: illuminated initials, interlace headpieces, red rubrics, uncial Coptic letters.
- The monastery's architecture: mud-brick and lime plaster walls, the keep (الحصن), domes, arches, desert light.
- Wadi El Natrun: sand, natron salt, evening light over the desert.
- Wall paintings and icons of the monastery: only as photographs the monastery permits; no icons or religious images are generated (AGENTS.md §2.7).
- All ornaments are drawn originally for the app; nothing is traced from existing works.

## Palette (tokens, to be tuned on real screens)
| Token | Role | Inspiration |
|---|---|---|
| Parchment | Light background | aged manuscript page |
| Lime plaster | Surfaces, cards | monastery walls |
| Iron-gall ink | Body text | manuscript ink |
| Cinnabar red | Rubrics: who speaks (priest / deacon / people), instructions, feast titles | red rubrics of liturgical books |
| Lapis | Accents, links, Coptic headings | lapis pigment of manuscripts |
| Leaf gold | Rare highlights only (feast days, illuminated initials) | gold leaf |
| Candle night | Dark mode: warm near-black with candle-gold text | reading by candle in the church |

## Typography
- Coptic: Unicode font (CS Ava Veni if permission is confirmed, else Noto Sans Coptic, DEC-P0-12); uncial feel for headings.
- Arabic reading: a classical Naskh with full tashkeel (candidates: Amiri, Scheherazade New, Noto Naskh Arabic — chosen by reading tests).
- Latin, Cyrillic: a classical serif for reading; Arimo only for small UI labels.

## Signature elements
1. **Illuminated initials**: the first letter of each prayer or reading drawn as a manuscript initial.
2. **Rubrics in cinnabar**: speaker and rite instructions in red, as in the printed books, also useful for following the service.
3. **Headpieces**: original interlace bands between sections.
4. **Page-turn motion**: a soft manuscript page turn in the reader; nothing flashy elsewhere.
5. **Candle mode**: the night theme, warm and dim, for the church and for night prayers.
6. **Feast pages**: on great feasts the home screen takes the feast's colour and a gold initial.
7. **Texture**: very light parchment and plaster grain, never reducing contrast.

## Beyond «luxury»: museum grade
- Monastery photography and 3D scans captured to heritage-documentation standard (with permission), so the tour and history sections read like a museum catalogue.
- Every historical statement carries its source, as in a scholarly edition.
- Accessibility at the same standard as the look: contrast checks on every token, screen readers, large type.

## Next
Three concept screens (home, parallel reader, «مرشدك») in light and candle modes, for the owner to choose and refine.
