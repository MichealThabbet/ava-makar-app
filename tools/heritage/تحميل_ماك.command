#!/bin/bash
cd "$(dirname "$0")"
python3 -m pip install -q truststore
echo "اسحب أيقونة الهارد الخارجي هنا ثم Enter:"; read D
echo "المكتبات: 1 = الفاتيكان | 2 = مكتبة الكونجرس | 3 = كتب التراث (archive.org) | 4 = المكتبة البريطانية | 5 = الكل | 6 = البريطانية: أرشيف خاص | 7 = أكسفورد | 8 = الأناجيل | 9 = ولكوم | 10 = مانشستر | 11 = باريس القبطي | 12 = بنسلفانيا"; read -p "رقم المكتبة: " L
CAT=vatican_full.json; [ "$L" = 2 ] && CAT=loc_full.json; [ "$L" = 3 ] && CAT=archive_org_books.json; [ "$L" = 4 ] && CAT=british_library_pd.json; [ "$L" = 6 ] && CAT=british_library_private.json; [ "$L" = 7 ] && CAT=bodleian.json; [ "$L" = 8 ] && CAT=gospels_manuscripts.json; [ "$L" = 9 ] && CAT=wellcome.json; [ "$L" = 10 ] && CAT=manchester.json; [ "$L" = 11 ] && CAT=bnf_coptic.json; [ "$L" = 12 ] && CAT=wikidata_coptic_iiif.json; [ "$L" = 5 ] && CAT="vatican_full.json loc_full.json archive_org_books.json british_library_pd.json bodleian.json wellcome.json manchester.json"
echo "الدرجات: 1 = القبطي | 2 = العربي المسيحي والسرياني والاثيوبي | 3 = اليوناني | 4 = الباقي"
read -p "اكتب الدرجات بينها مسافة (مثلا 1 2): " T
python3 download_iiif.py $CAT --out "${D//\'/}/Coptic_Heritage" --tier $T
read -p "انتهى. Enter للخروج"
