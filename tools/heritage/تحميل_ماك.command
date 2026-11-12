#!/bin/bash
cd "$(dirname "$0")"
python3 -m pip install -q truststore
echo "اسحب أيقونة الهارد الخارجي هنا ثم Enter:"; read D
echo "المكتبات: 1 = الفاتيكان | 2 = مكتبة الكونجرس | 3 = كتب التراث (archive.org) | 4 = الكل"; read -p "رقم المكتبة: " L
CAT=vatican_full.json; [ "$L" = 2 ] && CAT=loc_full.json; [ "$L" = 3 ] && CAT=archive_org_books.json; [ "$L" = 4 ] && CAT="vatican_full.json loc_full.json archive_org_books.json"
echo "الدرجات: 1 = القبطي | 2 = العربي المسيحي والسرياني والاثيوبي | 3 = اليوناني | 4 = الباقي"
read -p "اكتب الدرجات بينها مسافة (مثلا 1 2): " T
python3 download_iiif.py $CAT --out "${D//\'/}/Coptic_Heritage" --tier $T
read -p "انتهى. Enter للخروج"
