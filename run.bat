@echo off
cd /d "%~dp0"
if not exist env.json (
  echo Файл env.json не знайдено. Скопіюйте env.example.json у env.json і впишіть ключі.
  pause
  exit /b 1
)
flutter run -d windows --dart-define-from-file=env.json %*
