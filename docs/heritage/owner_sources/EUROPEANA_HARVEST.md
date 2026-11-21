# حصاد Europeana — النتيجة (مُختبَر 2026-11-21)

> بمفتاح Europeana API بتاع المالك. كله عدّ حقيقي من الـAPI، مش تقدير.

## الأرقام
- بحث بـ 6 مصطلحات (coptic, copte, koptisch, copto, bohairic, sahidic) → **4,348 عنصر فريد**.
- منها فيها IIIF/صورة قابلة للتحميل: **492**.
- بعد استبعاد **Gallica (عندنا أصلاً = 417)** و**Wellcome (عندنا)** و**أفلام Cinecittà (9)**: **الجديد الصافي = 60 عنصر**.

## الـ60 الجديدة (مرشّحة — في `europeana_coptic_candidates.json`)
| المزوّد | عدد | ملاحظة |
|---|---|---|
| Bavarian State Library (مكتبة بافاريا) | 46 | كتب ونحو قبطي (Koptische Grammatik…) — IIIF على digitale-sammlungen.de |
| National Library of Israel (إسرائيل الوطنية) | 5 | — |
| Digital Memory of Catalonia | 4 | — |
| Catalogo IMAGO (إيطاليا) | 2 | — |
| John Carter Brown / Barcelona / Graz | 3 | قطعة لكل واحد |

## الحالة الصادقة 🔴
- **لسه مرشّحين مش مؤكّدين:** هوست بافاريا (`api.digitale-sammlungen.de`) وإسرائيل (`www.nli.org.il`) **محجوبين عن شبكتي** (كود 000).
- **مش هعتمدهم ولا أحمّلهم** لحد ما تتفتح الشبكة لهم وأتأكد إن الـmanifests شغّالة وقبطي فعلاً.

## الخطوة الجاية
فتح الشبكة لـ `api.digitale-sammlungen.de` (+ هوست إسرائيل) → أتأكد وأحوّلهم لكتالوج معتمد `bavarian_coptic.json`.
