#!/bin/bash
cd "$(dirname "$0")"
echo "اسحب أيقونة الهارد الخارجي هنا ثم Enter:"; read D
echo "1 = القبطي والبرديات | 2 = العربي المسيحي والسرياني والاثيوبي | 3 = اليوناني | 4 = الأرمني والمختلط"
read -p "اكتب الدرجات بينها مسافة (مثلا 1 2): " T
python3 download_iiif.py vatican_full.json --out "${D//\'/}/Coptic_Heritage" --tier $T
read -p "انتهى. Enter للخروج"
