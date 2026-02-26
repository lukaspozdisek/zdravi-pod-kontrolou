@echo off
setlocal EnableExtensions
cd /d "%~dp0"

echo START WEB
echo Project: %CD%
echo ===============================

REM Add Rust to PATH (optional)
set "PATH=%PATH%;%USERPROFILE%\.cargo\bin"

REM Verify Flutter
where flutter >nul 2>nul
if not "%ERRORLEVEL%"=="0" (
  echo [ERROR] Flutter not found in PATH for CMD.
  echo Add Flutter bin (e.g. C:\src\flutter\bin) to User PATH.
  pause
  exit /b 1
)

echo Flutter OK:
flutter --version
echo.

echo Running pub get...
flutter pub get
if not "%ERRORLEVEL%"=="0" (
  echo [ERROR] flutter pub get failed.
  pause
  exit /b 1
)

echo.
echo Launching Chrome...
flutter run -d chrome

echo.
echo (Finished)
pause