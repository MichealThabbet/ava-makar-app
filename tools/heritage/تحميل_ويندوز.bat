@echo off
chcp 65001 >nul
cd /d "%~dp0"
set /p DRIVE=اكتب حرف الهارد الخارجي (مثلا E) ثم Enter: 
echo.
echo 1 = المخطوطات القبطية والبرديات
echo 2 = العربي المسيحي والسرياني والاثيوبي
echo 3 = اليوناني (الكتاب المقدس والآباء)
echo 4 = الأرمني ومجموعات شرقية مختلطة
set /p TIERS=اكتب الدرجات اللي عايزها بينها مسافة (مثلا 1 2) ثم Enter: 
python download_iiif.py vatican_full.json --out "%DRIVE%:\Coptic_Heritage" --tier %TIERS%
if errorlevel 9009 echo Python غير مثبت: نزله من python.org وعلّم Add to PATH
pause
