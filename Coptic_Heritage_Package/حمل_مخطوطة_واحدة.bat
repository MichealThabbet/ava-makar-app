@echo off
chcp 65001 >nul
set PYTHONUTF8=1
set BASE=%~dp0
python -m pip install -q truststore pillow tifffile imagecodecs 2>nul
echo ============================================
echo   تحميل مخطوطة واحدة برقمها
echo   مثال: Vat.ar.460   او   BnF Arabe 278   او   Vat.copt.64
echo ============================================
set /p DRIVE=حرف الهارد (مثلا E):
set /p MS=رقم المخطوطة:
cd /d "%BASE%2_catalogs"
python "%BASE%1_program\download_iiif.py" ruhban_masri.json vatican_full.json vatican_rest.json bnf_coptic.json --out "%DRIVE%:\Coptic_Heritage" --only "%MS%"
echo.
echo تم. الصور في %DRIVE%:\Coptic_Heritage
pause
