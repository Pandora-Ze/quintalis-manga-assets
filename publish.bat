@echo off
setlocal
cd /d "%~dp0"

echo === Publication des pages Scantrad vers GitHub ===

git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 goto git_error

for /f "delims=" %%B in ('git branch --show-current') do set "CURRENT_BRANCH=%%B"
if /i not "%CURRENT_BRANCH%"=="main" (
  echo ERREUR : le depot est sur la branche "%CURRENT_BRANCH%" au lieu de "main".
  goto failed
)

git add -A -- .
if errorlevel 1 goto git_error

git diff --cached --quiet
if not errorlevel 1 (
  echo Aucun changement detecte. Les fichiers locaux sont deja identiques a Git.
  git status --short --branch
  goto success
)

echo Changements detectes :
git diff --cached --stat
git commit -m "Mise a jour des pages Scantrad"
if errorlevel 1 goto git_error

git push origin main
if errorlevel 1 goto git_error

echo.
echo Publication terminee sur GitHub, branche main.
echo Le CDN peut prendre un court instant avant de servir les nouvelles images.
git status --short --branch
goto success

:git_error
echo.
echo ERREUR : Git n'a pas pu terminer l'operation. Verifiez le message ci-dessus.
goto failed

:success
echo.
pause
exit /b 0

:failed
echo.
pause
exit /b 1
