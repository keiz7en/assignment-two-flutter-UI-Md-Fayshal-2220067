@echo off
setlocal
cd /d "%~dp0"
echo IUB Assignment 2 - Flutter Setup
where flutter >nul 2>nul
if errorlevel 1 (
  echo Install Flutter and add its bin folder to PATH first.
  pause
  exit /b 1
)
call flutter doctor
call flutter create --platforms=android .
if errorlevel 1 goto error
call flutter pub get
if errorlevel 1 goto error
call flutter analyze
if errorlevel 1 goto error
call flutter test
if errorlevel 1 goto error
echo Setup complete. Connect your phone or emulator, then run: flutter run
pause
exit /b 0
:error
echo Setup stopped. Fix the error shown above, then rerun this file.
pause
exit /b 1
