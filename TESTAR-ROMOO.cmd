@echo off
setlocal
cd /d "%~dp0"
echo ====================================
echo   RoMoo io - Teste no Roblox Studio
echo ====================================
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Build-Test.ps1"
if errorlevel 1 (
  echo.
  echo ERRO na preparacao do teste. Envie a mensagem para revisao.
)
echo.
pause
