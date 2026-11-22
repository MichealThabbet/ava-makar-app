# الحصّاد الشامل — الضربة القاضية

سكربتان يشتغلوا على جهازك (متصفح حقيقي يعدّي Cloudflare):

## 1) الحصاد الخام الكامل
```
pip install playwright
playwright install chromium
python harvest_all.py            # كل المكتبات
python harvest_all.py laurenziana   # مكتبة واحدة
python harvest_all.py --list     # اعرض المتاح
```
- بيفتح Chrome (سيبه مفتوح).
- بيحفظ **كل سجل خام** في `raw/<lib>.json` — من غير ما يرمي حاجة.
- resumable: لو وقف، شغّله تاني يكمّل.

## 2) الفلترة المسيحية (منفصلة، قابلة للمراجعة)
```
python filter_christian.py
```
بيطلّع لكل مكتبة في `filtered/`:
- `<lib>.keep.json`  = المسيحي المقبول
- `<lib>.maybe.json` = مشكوك فيه (عنوان فاضي/مش واضح) ← راجعه
- `<lib>.drop.json`  = المرفوض (علماني/يهودي/إسلامي) ← اتأكد منه

**ليه خطوتين؟** عشان نشوف بالظبط إيه اللي اترمى وليه، ونتأكد مفيش مسيحي ضاع.

## إضافة مكتبة جديدة
زوّد سطر في `SOURCES` جوّه `harvest_all.py`:
- `oai` (ContentDM/OAI-PMH): endpoint=oai.php، set=اسم المجموعة
- `iiif_coll`: endpoint=رابط collection.json
- `blacklight`: endpoint=.../catalog.json، q=كلمة البحث
