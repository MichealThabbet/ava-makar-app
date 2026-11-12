@echo off
chcp 65001 >nul
cd /d "%~dp0"
set /p DRIVE=اكتب حرف الهارد الخارجي (مثلا E) ثم Enter: 
echo.
echo المكتبات:  1 = الفاتيكان    2 = مكتبة الكونجرس    3 = الاتنين (الفاتيكان الأول)
set /p LIB=اختار رقم المكتبة ثم Enter: 
set CAT=vatican_full.json
if "%LIB%"=="2" set CAT=loc_full.json
if "%LIB%"=="3" set CAT=vatican_full.json loc_full.json
echo.
echo الدرجات:  1 = القبطي   2 = العربي المسيحي والسرياني والاثيوبي   3 = اليوناني   4 = الباقي
set /p TIERS=اكتب الدرجات بينها مسافة (مثلا 1 2) ثم Enter: 
python download_iiif.py %CAT% --out "%DRIVE%:\Coptic_Heritage" --tier %TIERS%
if errorlevel 9009 echo Python غير مثبت: نزله من python.org وعلّم Add to PATH
pause
