# فهرس شغل مشروع آفا-مقار — كل اللي اتعمل (خريطة + تقرير)

> **الغرض:** ملف واحد يوريك **كل** شغل المشروع، مكانه، وحالته — عشان مفيش حاجة تضيع ولا تتوه.
> **تاريخ التقرير:** 2026-11-21 · **الفرع:** `codex/p0-plan` · **المستودع:** github.com/MichealThabbet/ava-makar-app
> **حالة الرفع وقت كتابة التقرير:** ✅ شجرة العمل نضيفة، مفيش ملف غير مرفوع، ومفيش commit محلي مش متدفوع. كله على GitHub.
> **الرموز:** ✅ خلص ومختبَر · ⚙️ شغّال/مجرّب على عيّنات · 🟡 أساس موجود مش منتَج نهائي · 📄 وثيقة/مرجع

---

## 0. خريطة المستودع (ابدأ من هنا)

| المجلد | فيه إيه |
|---|---|
| **الجذر** | ملفات الحوكمة: `HANDOFF.md`, `AGENTS.md`, `DECISIONS.md`, `GOAL.md`, `CLAUDE.md`, `README.md` |
| `packages/coptic_calendar/` | محرك التقويم القبطي (Dart) — مختبَر |
| `app/` | تطبيق Flutter (معاينة تصميم: هوم، قارئ، جولة…) |
| `tools/heritage/` | **برنامج تحميل المخطوطات + 29 كتالوج** + مشغّلات ويندوز/ماك |
| `docs/heritage/` | الحصر العالمي + خطابات الطلب + قوائم المخطوطات |
| `docs/plan`, `docs/foundation`, `docs/adr`, `docs/spec` | الخطط والرؤية وقرارات المعمار والمواصفات |
| `docs/design`, `docs/content` | اتجاه التصميم + جرد المحتوى والخطوط القبطية |
| `Coptic_Heritage_Package/` | نسخة منظّمة من البرنامج + الكتالوجات (برنامج في فولدر، كتالوجات في فولدر) |

---

## 1. وثائق الحوكمة والتخطيط 📄

| الملف | السطور | المحتوى |
|---|---|---|
| `HANDOFF.md` | 574 | سجل المشروع الجاري: المالك، الميزانية، القواعد، آخر نقطة. **المرجع الأساسي.** |
| `AGENTS.md` | 85 | القواعد الثابتة (سلامة النص المقدّس، الفرع، ممنوع force-push بدون المالك) |
| `DECISIONS.md` | 49 | سجل القرارات المعتمدة (DEC-P0-xx) |
| `GOAL.md` | 43 | قائمة أهداف المراحل |
| `docs/plan/MASTER_PLAN.md` + `P0_ADDENDUM.md` + `WORK_PLAN_2026-11.md` | — | الخطة الرئيسية والملحق وخطة شهر 11 |
| `docs/foundation/` | — | الرؤية (`PROJECT_VISION`) + مخطط المنتج (`PRODUCT_BLUEPRINT_V1`) |
| `docs/adr/ADR-001-stack.md` | — | قرار المعمار: الـstack واتجاه "Old Coptic Luxury" |
| `docs/spec/RETREAT_HOUSE_SOURCE_2026-11-04.md` | — | مواصفة بيت الخلوة |

---

## 2. محرك التقويم القبطي ✅ `packages/coptic_calendar/`

- `lib/coptic_calendar.dart` — التحويلات، عيد القيامة بطريقتين، الأعياد المتحركة، الصيام، فترات الطقس.
- `test/calendar_test.dart` + `test/rites_test.dart` — **اختبارات (منها تحقّق مقابل تقويم 2020–2100 = 2,343 حدث).**
- **الحالة:** أقوى جزء خلص ومختبَر. ده المحرك اللي يحسب "يوم القطمارس" و الأعياد.

---

## 3. تطبيق Flutter 🟡 `app/lib/`

شاشات موجودة: `home.dart`, `reader.dart`, `library.dart`, `book_detail.dart`, `search.dart`, `tour.dart`, `services.dart`
تصميم: `design/tokens.dart`, `design/book_cover.dart`, `design/ornaments.dart`, `design/components.dart`, `widgets/ornament.dart`
بيانات: `data/library.dart`
- **الحالة:** معاينة تصميم ويب شغّالة (Pages workflow) — مش تطبيق نهائي منشور بكل الوظائف.

---

## 4. التصميم والمحتوى 📄

- `docs/design/`: `DESIGN_DIRECTION.md`, `DESIGN_SYSTEM.md`, `HOME_AUDIT.md`
- `docs/content/`: `INVENTORY.md`, `LIBRARY_INVENTORY.md`, `IMPORT_REPORT.md`, `COPTIC_LEGACY_FONTS.md` + `img/` + `sources/`
- جرد التطبيقات الموجودة (شغل "الفك"): جرد تطبيق دير أنبا مقار + جرد محتوى تطبيق أبونا متى المسكين (في سجل الـcommits وملفات المحتوى).

---

## 5. التراث والمخطوطات — القلب ⚙️

### 5.أ البرنامج `tools/heritage/`
- `download_iiif.py` — المحرّك: يحمّل IIIF (manifest/canvas) + معالجات خاصة (Bodleian ZIP، Met API، روابط مباشرة، OPenn) + استكمال التحميل (Range) + fallback للدقة القصوى.
- مُشغّلات جاهزة: `تحميل_ويندوز.bat`, `تحميل_ماك.command`, `README_AR.md`, `الفهارس_المتاحة.txt`
- هارفسترات تشتغل من جهازك: `harvest_morgan.py`, `harvest_gallica.py`, `harvest_collection.py`, `onb_capture.cjs`
- **الحالة:** مجرّب فعلياً على Bodleian/Vatican/Penn وغيرهم. مش كل الـعناصر اتحمّلت end-to-end (ده بيحصل وقت التشغيل عندك).

### 5.ب الكتالوجات (29 ملف · ~17,911 عنصر)

| الكتالوج | عدد | ملاحظة |
|---|---|---|
| claremont_nha | 3,474 | |
| vatican_full | 2,871 | مكتبة كاملة (مش كلها قبطي) |
| loc_full | 2,720 | مكتبة كاملة (مش كلها قبطي) |
| claremont_cce | 2,131 | موسوعة قبطية |
| met_coptic | 1,966 | متحف المتروبوليتان (قبطي) |
| archive_org_books | 1,147 | كتب |
| bodleian | 937 | 568 يوناني/78 أرمني/54 قبطي/32 Huntington |
| watson_kharga | 453 | أرشيف الخارجة |
| gospels_manuscripts | 437 | أناجيل |
| bnf_coptic | 303 | باريس |
| berlin_coptic | 219 | برلين |
| cambridge_coptic | 218 | ميخائيليدس |
| duke_coptic | 207 | بردي |
| british_library_private | 198 | |
| british_library_pd | 142 | |
| claremont_aot | 122 | |
| claremont_bia | 108 | |
| princeton_coptic | 77 | |
| penn_digital_coptic | 49 | |
| chester_beatty | 30 | |
| upenn_coptic | 20 | |
| auc_coptic | 17 | الجامعة الأمريكية |
| openn_coptic | 17 | |
| wikidata_coptic_iiif | 17 | |
| wellcome | 15 | منسّق يدوي |
| manchester | 12 | |
| epiphanius | 2 | |
| dartmouth | 1 | |
| onb_coptic | 1 | النمسا |
| **الإجمالي** | **≈17,911** | عدّ خام — فيه تداخل محتمل والمجموعات "الكاملة" مش كلها قبطي |

### 5.ج الحصر العالمي `docs/heritage/`
- `01_المرحلة_الأولى_الدول.md` (325 س) — حصر 35 دولة (معتمد من المالك).
- `02_المرحلة_الثانية_المدن_والمؤسسات.md` (331 س) — 304 مؤسسة (دولة→مدينة→مؤسسة).
- `WORLD_COPTIC_INVENTORY.txt` (932 س) — الحصر العالمي الخام.
- `cce_museums_coptic_collections.txt` (1291 س) + `cce_papyrus_collections.txt` (177 س) — مصادر الموسوعة القبطية الأصلية.
- `HMML_INVENTORY_AND_KEYWORDS.md` + `search_keywords.txt` (180 س) — جرد HMML + ثيسورس كل تهجئات الأسماء للبحث.
- `GOSPEL_MANUSCRIPTS.md` (499 س) — مخطوطات الأناجيل.

### 5.د قوائم وخطابات الطلب
- `ABMQ_LIST.md` (88 س) — **الـ82 مخطوطة دير أنبا مقار** بأرقامها وروابطها.
- `HMML_REQUEST_LETTER.md` (138 س) — خطاب طلب الـ82 من HMML (جاهز للإرسال).
- `BL_REQUEST_LETTER.md` + `PATHS_REQUEST_LETTER.md` — خطابات للمكتبة البريطانية ومشروع PAThs.

### 5.هـ الحزمة المنظّمة `Coptic_Heritage_Package/`
نسخة مرتّبة: `1_program/` (البرنامج) + `2_catalogs/` (الكتالوجات) + مشغّلات ويندوز/ماك + `اقرأني_أولاً.txt`.

---

## 6. حالة كل محور بإيجاز

| المحور | الحالة |
|---|---|
| التقويم القبطي | ✅ خلص ومختبَر |
| جرد التطبيقات القديمة | ✅ اتعمل |
| برنامج تحميل المخطوطات + الكتالوجات | ⚙️ شغّال، مجرّب على عيّنات |
| الحصر العالمي (مرحلة 1 و2) | ✅ موثّق · مرحلة 3 (الجدول المتكامل) لسه |
| خطابات الطلب (HMML/BL/PAThs) | ✅ جاهزة للإرسال |
| تطبيق Flutter / الموقع | 🟡 معاينة، مش نهائي |
| بيت الخلوة | 🟡 مواصفة + قرار، مش شاشات نهائية |
| "قطمارس اليوم" كفيتشر مربوط بالنصوص | 🟡 المحرك جاهز، الربط بالشاشة لسه |

---

## 7. الناقص بأمانة (مش متعمل لسه)
- مرحلة 3 من الحصر العالمي: الجدول المتكامل القابل للبحث.
- تشغيل تحميل فعلي كامل على هارد (الكتالوجات جاهزة، التنزيل بيتم عندك).
- ربط "قطمارس اليوم" بشاشة شغّالة بالنصوص المعتمدة.
- تطبيق/موقع نهائي منشور بكل الوظائف.
- ABMQ (دير أنبا مقار): محجوب من vHMML — بيتجاب بخطاب HMML الرسمي، مش بالبرنامج.

---

## 8. إزاي تضمن إن الشغل ميضيعش عندك
1. **هو محفوظ دلوقتي على GitHub** على فرع `codex/p0-plan`.
2. نسخة مضغوطة لجهازك: من صفحة الريبو → Code → Download ZIP.
3. أو بـ git: `git clone https://github.com/MichealThabbet/ava-makar-app.git`
4. الفرع اللي فيه كل الشغل اسمه: **`codex/p0-plan`**.
