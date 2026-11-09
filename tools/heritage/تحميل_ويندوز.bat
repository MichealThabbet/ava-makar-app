@echo off
chcp 65001 >nul
cd /d "%~dp0"
set /p DRIVE=اكتب حرف الهارد الخارجي (مثلا E) ثم Enter: 
python download_iiif.py vatican_coptic.json --out "%DRIVE%:\Coptic_Heritage"
if errorlevel 9009 echo Python غير مثبت: نزّله من python.org وعلّم Add to PATH
pause
