# Legacy Coptic fonts → Unicode

The Coptic in the Library (Kholagy, Psalmody, Holy Week `dallal`) is plain ASCII typed for two legacy fonts. To show it with Noto Sans Coptic, search it, and keep it portable, the importer converts it to Unicode Coptic (U+2C80–2CFF, U+03E2–03EF). The original is kept in `segment.raw`.

## How the mapping was established (no guessing)
1. **Fonts from the source app.**
   - `orsozxi/RECOVERED_CODE/resources/assets/Avva_Shenouda.ttf` and `Athanasius.TTF`.
   - Their glyph names are plain ASCII (`a`, `b`, …), so they say nothing about the letter.
2. **Glyph sheets.** Every ASCII character was rendered in each font and read as a Coptic letter:
   - Avva: `img/avva_sheet.webp`.
   - Avva (black) vs Athanasius (blue): `img/ath_sheet.webp`.
3. **Marks.** The font metrics tell where each mark sits:
   - `` ` `` and `~` (jinkim) have zero advance and sit over the **next** letter.
   - Athanasius `/` and `?` (overline) have a negative x-offset and sit over the **previous** letter.
   - Avva `=` sits over the next letter.
4. **Cross-check with the Arabized column of the same row.** Examples:
   - `ctaqhte` = «إسطاثيتي»
   - `` `njom `` = «إن جوم»
   - `oucaji` = «اوصاﭽي»
   - `` `nje `` = «إنجي»
5. **End-to-end visual check:** 12 random converted lines, the legacy font above and Noto Sans Coptic below (`img/coptic_verify.webp`). All letters and marks match.

## Rules
- Convert exactly what the font displays.
- Glyphs that are empty in the font are dropped, because readers never saw them. Avva: `, > 1 8 9 ( ) { } | _ " <`
- Glyphs not verified are **kept as-is and reported** (`meta.unmapped`, issue `info`), never guessed. Each is under 30 uses:
  - Avva `U` and `+` (ligatures).
  - Athanasius `=` and `+`.
- Jinkim → U+0300 after the letter; overline → U+0305 after the letter.
- Decorative crosses → ✠ ✣ ✝ ✟ ✥ (no liturgical meaning).
- The font is detected per cell (`detect_font`):
  - **Avva signs:** digits joined to letters (`a42wpi`).
  - **Athanasius signs:** `[ ] \ { } |`, a leading `'`, a trailing `>`.
  - **Default:** per book.

## Letter tables

| Letter | Avva Shenouda | Athanasius |
|---|---|---|
| ⲁ ⲃ ⲥ ⲇ ⲉ ⲓ ⲕ ⲗ ⲙ ⲛ ⲟ ⲡ ⲣ ϭ ⲧ ⲱ ⲭ ⲯ ⲍ | a b c d e i k l m n o p r s t w x y z | same |
| ⲅ | j | g |
| ⲏ | 3 (Ⲏ #) | h |
| ⲑ | 0 (Ⲑ `)`) | q |
| ⲩ | v | u |
| ⲫ | f | v |
| ⲝ | 7 (Ⲝ &) | [ (Ⲝ {) |
| ϣ | 2 (Ϣ @) | ] (Ϣ }) |
| ϥ | 4 (Ϥ $) | f |
| ϧ | q | ' (Ϧ ") |
| ϩ | h | \ (Ϩ \|) |
| ϫ | g | j |
| ϯ | 5 (Ϯ %) | ; (Ϯ :) |
| ⲋ | 6 (Ⲋ ^) | , (Ⲋ <) |
| ⲟ̅ⲥ̅ | u | _ |
| Ⲭ̅ⲉ̅ | ! | — |
| `:` `;` `,` `?` | `:` `;` — `?` | `>` `^` `%` `&` |

Upper case follows the letter (e.g. `A` = Ⲁ) except where a separate key is shown.

Code: `tools/import/ava_import/coptic_legacy.py`. Tests: `tools/import/tests/test_units.py`.
