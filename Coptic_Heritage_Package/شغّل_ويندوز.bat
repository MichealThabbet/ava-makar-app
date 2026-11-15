@echo off
chcp 65001 >nul
set PYTHONUTF8=1
set BASE=%~dp0
echo ============================================================
echo    تحميل التراث القبطي  -  دير أنبا مقار   (28 مكتبة)
echo ============================================================
python --version >nul 2>&1 || (echo Python غير مثبت: نزله من python.org وعلم Add to PATH ثم اعد التشغيل & pause & exit /b)
python -m pip install -q truststore pillow 2>nul
echo.
set /p DRIVE=اكتب حرف الهارد الخارجي (مثلا E) ثم Enter:
echo.
echo المكتبات:
echo   1=الفاتيكان 2=الكونجرس 3=كتب archive 4=البريطانية عام 6=البريطانية خاص
echo   7=بودليان 8=الاناجيل 9=ولكوم 10=مانشستر 11=باريس 12=Wikidata 13=بنسلفانيا
echo   14=برينستون 15=تشستر بيتي 16=الموسوعة القبطية 17=نجع حمادي 18=اثار المعهد
echo   19=نشرة المعهد 20=دارتموث 21=OPenn 22=بنسلفانيا رقمي 23=الامريكية بالقاهرة
echo   24=المتروبوليتان 25=النمسا 26=حفائر الخارجة 27=دير ابيفانيوس 28=كامبريدج 29=ديوك
echo.
echo   5  = الكبار معا        99 = حمل كل المكتبات (كل الكنز)
echo.
set /p LIB=اختار رقم المكتبة ثم Enter:

set CAT=vatican_full.json
if "%LIB%"=="2" set CAT=loc_full.json
if "%LIB%"=="3" set CAT=archive_org_books.json
if "%LIB%"=="4" set CAT=british_library_pd.json
if "%LIB%"=="6" set CAT=british_library_private.json
if "%LIB%"=="7" set CAT=bodleian.json
if "%LIB%"=="8" set CAT=gospels_manuscripts.json
if "%LIB%"=="9" set CAT=wellcome.json
if "%LIB%"=="10" set CAT=manchester.json
if "%LIB%"=="11" set CAT=bnf_coptic.json
if "%LIB%"=="12" set CAT=wikidata_coptic_iiif.json
if "%LIB%"=="13" set CAT=upenn_coptic.json
if "%LIB%"=="14" set CAT=princeton_coptic.json
if "%LIB%"=="15" set CAT=chester_beatty.json
if "%LIB%"=="16" set CAT=claremont_cce.json
if "%LIB%"=="17" set CAT=claremont_nha.json
if "%LIB%"=="18" set CAT=claremont_aot.json
if "%LIB%"=="19" set CAT=claremont_bia.json
if "%LIB%"=="20" set CAT=dartmouth.json
if "%LIB%"=="21" set CAT=openn_coptic.json
if "%LIB%"=="22" set CAT=penn_digital_coptic.json
if "%LIB%"=="23" set CAT=auc_coptic.json
if "%LIB%"=="24" set CAT=met_coptic.json
if "%LIB%"=="25" set CAT=onb_coptic.json
if "%LIB%"=="26" set CAT=watson_kharga.json
if "%LIB%"=="27" set CAT=epiphanius.json
if "%LIB%"=="28" set CAT=cambridge_coptic.json
if "%LIB%"=="29" set CAT=duke_coptic.json
if "%LIB%"=="5"  set CAT=vatican_full.json loc_full.json archive_org_books.json british_library_pd.json bodleian.json wellcome.json manchester.json
if "%LIB%"=="99" set CAT=vatican_full.json loc_full.json archive_org_books.json british_library_pd.json british_library_private.json bodleian.json gospels_manuscripts.json wellcome.json manchester.json bnf_coptic.json wikidata_coptic_iiif.json upenn_coptic.json princeton_coptic.json chester_beatty.json claremont_cce.json claremont_nha.json claremont_aot.json claremont_bia.json dartmouth.json openn_coptic.json penn_digital_coptic.json auc_coptic.json met_coptic.json onb_coptic.json watson_kharga.json epiphanius.json cambridge_coptic.json duke_coptic.json

echo.
echo الدرجة (اختياري): 1 = القبطي المباشر فقط  ^|  اضغط Enter فقط لتحميل كل شيء
set /p TIERS=اكتب الدرجات بمسافة او اضغط Enter:
set TIERARG=
if not "%TIERS%"=="" set TIERARG=--tier %TIERS%

echo.
echo جاري التحميل الى %DRIVE%:\Coptic_Heritage  (يمكن ايقافه Ctrl+C واعادة تشغيله ليكمل)
rem المجلد الحالي = فولدر الفهارس، والسكربت من فولدر البرنامج
cd /d "%BASE%2_catalogs"
python "%BASE%1_program\download_iiif.py" %CAT% --out "%DRIVE%:\Coptic_Heritage" %TIERARG% --pause 0.3
echo.
echo تم. لو توقف قبل الاكتمال شغل الملف مرة اخرى.
pause
