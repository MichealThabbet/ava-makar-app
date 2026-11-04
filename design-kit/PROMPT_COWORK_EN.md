# Design prompt — Home page of the app of «St Macarius the Great Monastery, Scetis (Wadi El Natrun)»

> Copy everything below the line into Cowork and upload the whole zip file with it.

---

## 1. Your role
You are an Art Director and senior UI designer specialised in ultra-luxury Old Coptic Orthodox design, and a front-end developer.
Design and build the monastery app's **home page** as a working web page (HTML + CSS + JavaScript), mobile first.

The bar: when users open the page they must feel they are entering an ancient, majestic Coptic church — real metallic gold, old paper, wood, candles, soft light, calm cinematic motion.
**Not** an ordinary brown website template, and not repeated identical cards.

## 2. Binding rules (from the project owner)
1. **Use only the images and assets in the zip.** Do not generate images, do not fetch images from outside, do not swap an image for a similar one.
2. **Never invent religious text** — no verses, sayings, news, dates or numbers. All texts are in `08_content/data.js` and `08_content/news.md`. Anything missing is shown elegantly as «يُضاف» (to be added); never invent content.
3. **Official name:** «دير القديس أنبا مقار الكبير ببرية شيهيت». The ready-made name images read «دير القديس العظيم أنبا مقار الكبير».
4. **All headings in Ruqaa (Aref Ruqaa Bold), in true metallic gold:**
   - Raised edge (bevel).
   - Specular highlight that moves slowly.
   - Depth under the letter (extrusion).
   - Drop shadow.
   - **No** dull gold, no dark brown band through the middle, no flat gold.
5. **Text is bold and large, with a text-shadow** on any dark background. Smallest text on the page: 13 px.
6. **No text placed over photos** where it covers their details.
7. **Every image must be sharp, never pixelated, on an iPhone (3x) screen.** Never scale an image beyond its native resolution.
8. **No cut-out marks, white fringes or red/yellow halos around any cut-out element.** Most heading images arrive with a colour halo and must be cleaned. Cleaned versions are in `04_names_and_titles/*-cleaned.*`.
9. **Colours:** the dark brown must match `01_backgrounds/background-dark-brown-reference.jpg`. The gold must match the gold of the name and heading images.
10. **Layout:**
    - 8-pt spacing grid.
    - Fixed 20 px side gutter.
    - Fixed vertical rhythm between sections.
    - Fixed type scale (1.25).
    - Only three shadow levels and only two corner radii.
11. **Variety:** cards must not all share one shape, and must not be all light or all dark. Alternate light old paper with dark leather and wood. Every card has a shadow and motion.
12. **Motion:**
    - Cinematic and calm, never fast.
    - Each section has its own signature movement, not the same fade-up everywhere.
    - Stops under `prefers-reduced-motion`.
    - Light on iPhone Safari: bake shadows into images where possible; avoid many `filter: drop-shadow`.
13. **Base design width 390 px.** Also check 360, 430, 768 and 1440. No horizontal scrolling.
14. **Direction: Arabic RTL.** Coptic text in Noto Sans Coptic.
15. **No decorative drop cap** if it breaks Arabic letter joining. Colour the whole first word instead of the first letter.

## 3. Fonts (in `09_fonts/`)
| Font | Use |
|---|---|
| **Aref Ruqaa Bold** | All headings and the monastery name |
| **Amiri** | Readings and long sayings; supports tashkeel |
| **Cairo** (variable) | Buttons, dates, descriptions, menus, in bold |
| **El Messiri** | Optional for sub-headings |
| **Noto Sans Coptic** | Coptic text |

## 4. Home page order (approved — do not change)
0. **Cinematic opening screen**
1. **Fixed header**
2. **Main photo show:** monastery photos
3. **Today's readings** (قراءات اليوم)
4. **Sayings of St Macarius the Great** (من أقوال القديس أنبا مقار الكبير)
5. **Sayings of Fr Matta El-Meskeen** (من أقوال أبونا متى المسكين), with a small photo
6. **Sayings of H.G. Anba Epiphanius** (من أقوال نيافة الأنبا إبيفانيوس), with a photo. Text and photo are still to come: build an elegant placeholder marked «يُضاف».
7. **Latest news** (آخر الأخبار)
8. **Your guide inside the monastery** (مرشدك داخل الدير)
9. **Two large cards:** «بيت الخلوة» (Retreat house) | a card split in two, «التبرعات» (Donations) and «طلبات الصلاة» (Prayer requests)
10. **Two boxes:** «آخر إصداراتنا» (Latest releases) | «منتجات الدير» (Monastery products)
11. **Footer:** quick links and «اتصل بنا» (Contact us). Phone, e-mail and address: «يُضاف».
- **Fixed bottom bar** with the five main sections.
- **☰ menu** with every section of the app (full list in section 7).

## 5. Section details

### 0. Cinematic opening (about 6–7 seconds, skippable with a tap)
- **Layers:** `02_intro_layers/`:
  - Background `intro-back-prepared.jpg`.
  - Saint `intro-saint-prepared-with-bottom-fade.webp`, with a gradient at the bottom.
- **Exact saint placement on the background** (942 × 1670): left 20.594 %, top 2.275 %, width 60.828 %. Computed by matching against the approved image `01_backgrounds/intro-approved-composite-saint-and-sanctuary.jpg`; the result must match it.
- **Shots:**
  1. Start from darkness, with faint incense smoke.
  2. The camera pushes in slowly. The saint moves at a different speed from the background (parallax), so there is depth.
  3. The halo brightens and dims; the sanctuary lamps flicker like candles.
  4. The name enters line by line, fade and zoom, using the cleaned images `04_names_and_titles/name-line-1/2/3-cleaned.webp`:
     - Line 1 «دير القدّيس العظيم».
     - Line 2 «أنبا مُقار الكبير», the largest line.
     - Line 3 «ببرية شيهيت», smaller, as a slogan.
  5. A gold sheen passes over the lines.
  6. Exit with fade + zoom forward, as if entering the church.
- **No** large gold cross on the opening screen — removed at the owner's request.
- **Note:** in `intro-new-background-with-chandelier.jpg` the sanctuary has different proportions and the wooden screen is of lower quality, so the saint must not be placed on it.

### 1. Header (always fixed, never hides)
- **Size:** 390 × 74 px.
- **Background:** `05_paper_leather_references/header-scroll-used-darkened-B.webp`. This tone is approved (the "second from the bottom" of the tones shown).
- **Centre:** «دير القديس أنبا مقار الكبير» in bold Ruqaa, metallic gold, with a slowly moving sheen.
- **Sides:** ☰ with «القائمة» (Menu) under it, and the magnifier with «بحث» (Search) under it.

### 2. Main photo show
- **Format:** **landscape** cinematic show; portrait is not allowed.
- **Frame:** clean old-paper edges with no cut marks, a simple thin gold frame inside, and a light outer shadow.
- **Ready frame:** `05_paper_leather_references/photo-frame-landscape-prepared.webp`. Size 1600 × 1220; the photo window inside: inset 8.4 % top, 7.6 % right and left, 9.8 % bottom.
- **Photos:** monastery photos in `03_monastery_photos/` change with a slow Ken Burns move. Each photo gets a focus point so the cross or the arch is never cropped.
- **No** text over the photos.
- **Height:** «قراءات اليوم» must be visible on the first screen.

### 3. Today's readings
- **Heading:** «قراءات اليوم» on a small old paper scroll (`05_paper_leather_references/section-title-scroll.webp`), sized to the heading, not the page width, and not tall. Text in metallic gold Ruqaa.
- **Cleaned heading images:** `04_names_and_titles/title-readings-1/2/3-cleaned.webp`. Pick the best one, or use the same style with the font.
- **Spacing:** the gap between the heading and the section above was too large and must be corrected.
- **Under the heading:** «الثلاثاء الموافق ٣ نوفمبر ٢٠٢٦ م ، ٢٤ بابه ١٧٤٣ ش».
- **Scene:** an open book (`05_paper_leather_references/open-book.jpg`) on the lectern with candles (`06_objects/lectern-with-candles.webp`).
  - The candle flames move, and their warm light falls on the pages.
  - The text on the pages is readable and follows the tilt of the pages.
- **Reading ribbons:** عشية (Vespers), باكر (Matins), البولس (Pauline), الكاثوليكون (Catholicon), الإبركسيس (Praxis), القداس (Liturgy), السنكسار (Synaxarium). All visible, none cut off. Tapping a ribbon turns the page; tapping the book opens the full text.
- **Texts** in `data.js`: `readings` and `synaxarium`. The readings carry tashkeel and are shown exactly as they are.

### 4, 5, 6. Sayings
- **One design family** for the three cards, with deliberate variation.
- **St Macarius:**
  - A rolled scroll that unrolls when reached, with a red wax seal reading ⲙⲁⲕⲁⲣⲓⲟⲥ.
  - A new saying each day from `data.js` > `macarius`.
- **Fr Matta El-Meskeen:** small photo (`07_people_and_news_images/fr-matta-el-meskeen.jpg`), a new saying each day from `data.js` > `matta`.
- **Anba Epiphanius:** places for the photo and the text, marked «يُضاف».
- **«قول آخر» (Another saying) button** on every card.
- **Long sayings:** «اقرأ المزيد» (Read more).

### 7. Latest news (3 real news items in `news.md` and `data.js` > `news`)
| News | Date | Images |
|---|---|---|
| تحذير هام بخصوص حسابات وصفحات مزورة على الفيسبوك (warning about fake Facebook accounts and pages) | 22 June 2026 | Screenshots of the fake accounts (`news-fake-*`), stamped «مزوّر» (fake) |
| نياحة الراهب القس ديمتري المقاري (repose of Fr Demetri El-Makari) | 25 April 2024 | Two photos |
| يودع دير القديس أنبا مقار على رجاء القيامة د. سعيد حكيم (the monastery bids farewell to Dr Said Hakim) | 30 August 2023 | His photo, with his piece «لماذا السفر الآن؟» |
- **Luxurious cards** in a horizontal swipe rail with an indicator.
- **News photos** get a warm tone that matches the page.
- **Each item has a full page:** the complete text exactly as given, footnotes as links, and the photos.

### 8. Your guide inside the monastery
A distinctive card in green Juniper leather, with a gold route drawing itself between the monastery's stations, and a «ابدأ الجولة» (Start the tour) button.

### 9 and 10. Services and releases
- **Unified icons** in the same metallic-gold style.
- **No** text over a busy photo.

### 11. Footer
- **Mark:** a small gold cross (`06_objects/coptic-cross-gold.webp`).
- **Name:** with «ببرية شيهيت» smaller beneath it.
- **Quick links styled as links:** قراءات اليوم، مرشدك داخل الدير، بيت الخلوة، التبرعات، طلبات الصلاة، منتجات الدير.
- **Contact us:** phone, e-mail and address (Wadi El Natrun), all «يُضاف».

### Page background
- **Ground:** `01_backgrounds/background-coptic-crosses.jpg`, fixed while the page scrolls over it.
- **Soft church lighting:** slanted light rays from above, warm light pools that breathe, and dust motes in the light. All very faint so reading is never disturbed.

## 6. Reading page (when a text is opened)
- **Background:** calm paper, with no moving gold or wood behind the text.
- **Font:** large Amiri, tashkeel kept exactly, verse numbers in red.
- **Above the text:** the reading's name and reference.
- **Between readings:** back and next.

## 7. ☰ menu (every section of the app)
- **الرئيسية (Home):** قراءات اليوم، آخر الأخبار، إرشادات هامة، خدمات الدير، القديس أنبا مقار الكبير، أحدث الإصدارات.
- **الصلوات والقراءات الكنسية (Prayers and readings):** قراءات وصلوات اليوم، التقويم القبطي والأعياد والأصوام، القطمارس، الأجبية، الخولاجي المقدس، السنكسار، الكتاب المقدس، الإبصلمودية والتسبحة والألحان، البصخة وأسبوع الآلام، كتب وخدمات طقسية أخرى.
- **جولة داخل دير أبو مقار (Tour of the monastery):** مرشدك داخل الدير، تاريخ الدير، كنيسة أنبا مقار الأثرية، كنيسة أبا سخيرون القليني، كنيسة الشهداء التسعة والأربعين، الحصن الأثري، القوس الأثري، قبة الميرون الأثرية، القلالي الأثرية، المائدة الأثرية، متحف الدير، قديسو الدير وآباؤه.
- **المكتبة والتراث والإصدارات (Library, heritage and publications):** مكتبة الدير، المخطوطات الأثرية، ما كُتب عن دير أبو مقار، مطبوعات الدير، مجلة مرقس وأرشيفها، مؤلفات وعظات آباء الدير، المكتبة الرقمية.
- **خدمات الدير (Monastery services):** بيت الخلوة، طلبات الصلاة، النذور والتبرعات، الزيارات، منتجات الدير.

## 8. Mistakes in the current version (do not repeat)
See `10_current_prototype/HOME_AUDIT.md` (43 points) and the screenshots in `10_current_prototype/screenshots/`. The main ones:
- No spacing grid and no fixed type scale.
- Brown on brown, and gold on everything.
- Section headings not unified.
- The photo show was portrait.
- The paper frame showed cut marks.
- The lectern and candles were drawn in code.
- The cards had no single family.
- The footer was poor.

`index.html`, `style.css` and `app.js` are a reference for data and behaviour only, **not** for the look.

## 9. Way of working and delivery
1. **Before writing code:** show a short moodboard, a wireframe of the page with proportions at 390 px, and the spacing and type scales. Wait for the owner's approval.
2. **Build section by section.** After each section, capture it at 390 px and show it.
3. **Before delivering anything, review it with a designer's eye:**
   - Spacing.
   - Proportions.
   - Image sharpness.
   - Clean edges.
   - Gold clarity.
   - Font sizes.
   - Overflow.
   - Motion.

   Fix everything you find before showing it.
4. **Delivery:** one working folder with `index.html`, `style.css`, `app.js`, `img/` and `fonts/`, that opens directly in a browser and can be published on GitHub Pages.
5. **State plainly** what you could not do or test, without flattery.
