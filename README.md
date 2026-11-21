# مشروع آفا–مقار — خريطة الشغل كله

> أول ما تفتح الريبو، ده بيوصّلك لكل حاجة. الشغل متقسّم **3 أقسام**: الموقع · البرامج · الأبحاث.
> **كل الشغل محفوظ على GitHub** على فرع `codex/p0-plan` — مفيش ملف ناقص.
> تفاصيل أدق لكل ملف: **[`docs/INDEX_OF_WORK.md`](docs/INDEX_OF_WORK.md)**

---

## 🌐 القسم 1 — الموقع والتطبيق (والتصميم والمراجعات)

تطبيق Flutter واحد بيطلع موقع ويب + أندرويد + iOS.

| الحاجة | المكان في الريبو |
|---|---|
| **الموقع المنشور (شغّال)** | https://michealthabbet.github.io/ava-makar-app/ |
| كود التطبيق/الموقع (الشاشات: هوم، قارئ، مكتبة، جولة، خدمات) | `app/lib/` |
| محرك التقويم القبطي (حساب القطمارس والأعياد) — **مختبَر** | `packages/coptic_calendar/` |
| التصميم (الاتجاه + نظام التصميم + مراجعة الهوم) | `docs/design/` |
| قرار المعمار (Old Coptic Luxury) | `docs/adr/ADR-001-stack.md` |
| النشر الآلي (CI) | `.github/workflows/web-preview.yml` |

## 🧰 القسم 2 — البرامج (تحميل المخطوطات)

البرنامج ده بيشتغل على **جهازك**، وبيحمّل ملايين الصفحات من 29 مكتبة.

| الحاجة | المكان في الريبو |
|---|---|
| **المحرّك** (تحميل IIIF + Bodleian ZIP + استكمال + أعلى دقة) | `tools/heritage/download_iiif.py` |
| **29 كتالوج · ~17,911 مخطوطة/قطعة** (مئات الصفحات لكل مخطوطة = ملايين الصور) | `tools/heritage/*.json` |
| مُشغّلات جاهزة (ويندوز/ماك) + دليل عربي | `tools/heritage/تحميل_ويندوز.bat` · `تحميل_ماك.command` · `README_AR.md` |
| هارفسترات تشتغل من جهازك (Morgan, Gallica, …) | `tools/heritage/harvest_*.py` · `onb_capture.cjs` |
| نسخة منظّمة جاهزة (برنامج + كتالوجات في فولدرين) | `Coptic_Heritage_Package/` |
| خط استيراد المحتوى (الكتب المقدّسة/الطقسية) | `tools/import/` + `data/content/` |

## 📚 القسم 3 — الأبحاث والحصر

| الحاجة | المكان في الريبو |
|---|---|
| **الحصر العالمي — مرحلة 1 (35 دولة)** | `docs/heritage/01_المرحلة_الأولى_الدول.md` |
| **الحصر العالمي — مرحلة 2 (304 مؤسسة)** | `docs/heritage/02_المرحلة_الثانية_المدن_والمؤسسات.md` |
| الحصر الخام الكامل | `docs/heritage/WORLD_COPTIC_INVENTORY.txt` |
| **قائمة الـ82 مخطوطة دير أنبا مقار** (أرقام + روابط) | `docs/heritage/ABMQ_LIST.md` |
| خطاب طلب الـ82 من HMML (جاهز للإرسال) | `docs/heritage/HMML_REQUEST_LETTER.md` |
| خطابات طلب أخرى (المكتبة البريطانية / PAThs) | `docs/heritage/BL_REQUEST_LETTER.md` · `PATHS_REQUEST_LETTER.md` |
| جرد HMML + ثيسورس كل تهجئات الأسماء للبحث | `docs/heritage/HMML_INVENTORY_AND_KEYWORDS.md` · `search_keywords.txt` |
| مخطوطات الأناجيل | `docs/heritage/GOSPEL_MANUSCRIPTS.md` |
| مصادر الموسوعة القبطية الأصلية | `docs/heritage/cce_*.txt` |

---

## الإدارة والحوكمة (مرجع)
`HANDOFF.md` (السجل الجاري) · `AGENTS.md` (القواعد) · `DECISIONS.md` · `GOAL.md` · `docs/plan/` (الخطط) · `docs/foundation/` (الرؤية) · `docs/spec/` (بيت الخلوة)

## تضمن إن الشغل ميضيعش
- محفوظ على GitHub: فرع **`codex/p0-plan`**.
- نسخة لجهازك: صفحة الريبو → **Code → Download ZIP**، أو `git clone https://github.com/MichealThabbet/ava-makar-app.git`
- مشاريعك التانية محفوظة لوحدها: `krvng5c6t9-rgb/-MISHEL-CONSTRUCTION-INTELLIGENCE-PLATFORM` · `MichealThabbet/defnar`
