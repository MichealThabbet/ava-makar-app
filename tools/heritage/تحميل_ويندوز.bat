@echo off
chcp 65001 >nul
set PYTHONUTF8=1
cd /d "%~dp0"
python -m pip install -q truststore
set /p DRIVE=اكتب حرف الهارد الخارجي (مثلا E) ثم Enter: 
echo.
echo المكتبات:  1 = الفاتيكان    2 = مكتبة الكونجرس    3 = كتب التراث القديمة (archive.org)    4 = المكتبة البريطانية    5 = الكل    6 = البريطانية: أرشيف خاص (198 مخطوطة)    7 = أكسفورد (Bodleian)    8 = مخطوطات الأناجيل    9 = ولكوم لندن    10 = جون رايلاندز مانشستر    11 = باريس القبطي (303)    12 = بنسلفانيا وأمريكا (Wikidata)
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
if "%LIB%"=="5" set CAT=vatican_full.json loc_full.json archive_org_books.json british_library_pd.json bodleian.json wellcome.json manchester.json
echo.
echo الدرجات:  1 = القبطي   2 = العربي المسيحي والسرياني والاثيوبي   3 = اليوناني   4 = الباقي    (للكتب: 1 = قبطي  2 = شرقي)
set /p TIERS=اكتب الدرجات بينها مسافة (مثلا 1 2) ثم Enter: 
python download_iiif.py %CAT% --out "%DRIVE%:\Coptic_Heritage" --tier %TIERS%
if errorlevel 9009 echo Python غير مثبت: نزله من python.org وعلّم Add to PATH
pause
