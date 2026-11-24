#!/bin/bash
cd "$(dirname "$0")"
python3 -m pip install -q truststore pillow tifffile imagecodecs 2>/dev/null
read -p "اكتب مسار مجلد الحفظ (مثلا /Volumes/HARD): " OUT
echo "المكتبات: 1=الفاتيكان ... 24=المتروبوليتان 25=النمسا 26=الخارجة 27=ابيفانيوس 28=كامبريدج 29=ديوك 30=برلين 31=كتب 32=BnF مسيحي 33=سيناء 34=الفاتيكان الباقي 35=بودليان الكامل 36=مانشستر الجديد 37=ييل 38=مورجان 39=لورنتسيانا 40=Fragmentarium 41=اوترخت 42=BnF مختارات 43=الحامولي Hyvernat 44=الدير الابيض مخطوطات 45=الدير الابيض مطبوعات 46=النمسا manuscripta 47=النمسا PDF 48=النمسا شذرات | 5=الكبار | 99=الكل"
read -p "رقم المكتبة: " L
declare -A M=( [1]=vatican_full [2]=loc_full [3]=archive_org_books [4]=british_library_pd [6]=british_library_private [7]=bodleian [8]=gospels_manuscripts [9]=wellcome [10]=manchester [11]=bnf_coptic [12]=wikidata_coptic_iiif [13]=upenn_coptic [14]=princeton_coptic [15]=chester_beatty [16]=claremont_cce [17]=claremont_nha [18]=claremont_aot [19]=claremont_bia [20]=dartmouth [21]=openn_coptic [22]=penn_digital_coptic [23]=auc_coptic [24]=met_coptic [25]=onb_coptic [26]=watson_kharga [27]=epiphanius [28]=cambridge_coptic [29]=duke_coptic [30]=berlin_coptic [31]=coptic_printed_books [32]=bnf_christian [33]=sinai_ucla [34]=vatican_rest [35]=bodleian_rest [36]=manchester_rest [37]=yale_coptic [38]=morgan_christian [39]=laurenziana [40]=fragmentarium [41]=utrecht [42]=gallica_owner_picks [43]=morgan_hyvernat_coptic [44]=white_monastery_mss [45]=white_monastery_books [46]=austria_manuscripta_iiif [47]=austria_pdfs [48]=austria_fragmentarium )
if [ "$L" = "99" ]; then CAT=$(cd 2_catalogs && ls *.json); elif [ "$L" = "5" ]; then CAT="vatican_full.json loc_full.json archive_org_books.json british_library_pd.json bodleian.json wellcome.json manchester.json"; else CAT="${M[$L]}.json"; fi
cd 2_catalogs
python3 ../1_program/download_iiif.py $CAT --out "$OUT/Coptic_Heritage" --pause 0.3
