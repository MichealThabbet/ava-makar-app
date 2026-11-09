#!/bin/bash
cd "$(dirname "$0")"
echo "اسحب أيقونة الهارد الخارجي هنا ثم Enter:"; read D
python3 download_iiif.py vatican_coptic.json --out "${D//\'/}/Coptic_Heritage"
read -p "انتهى. Enter للخروج"
