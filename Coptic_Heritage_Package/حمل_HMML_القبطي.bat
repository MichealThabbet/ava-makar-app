@echo off
chcp 65001 >nul
rem تنزيل صور HMML القبطية من Releases المستودع الخاص old-treasure-recovery- (محتاج GitHub CLI مسجل دخول)
rem 1) ثبت gh:  winget install --id GitHub.cli   2) سجل دخول:  gh auth login
set /p DRIVE=اكتب حرف الهارد (مثلا E) ثم Enter: 
set OUT=%DRIVE%:\Coptic_Heritage\HMML_releases
mkdir "%OUT%" 2>nul
gh release download hmml-coptic-open-images -R MichealThabbet/old-treasure-recovery- -D "%OUT%" --skip-existing
gh release download hmml-coptic-open-images-2 -R MichealThabbet/old-treasure-recovery- -D "%OUT%" --skip-existing
echo تم. كل ZIP فيه صورة/صور اصلية + ملف المصدر والبصمة.
pause
