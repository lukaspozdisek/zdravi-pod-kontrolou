@echo off
cd /d "%~dp0"

echo === PUB GET ===
call flutter pub get
if errorlevel 1 (
  echo pub get FAILED
  pause
  exit /b 1
)

echo.
echo === RUN CHROME ===
call flutter run -d chrome

echo.
echo === DONE / EXITED ===
pause