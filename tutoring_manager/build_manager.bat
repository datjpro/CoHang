@echo off
echo =====================================
echo   Tutoring Manager Build Script
echo =====================================
echo.

echo Checking Flutter environment...
flutter doctor
echo.

echo Choose build option:
echo 1. Run on Windows (requires Visual Studio)
echo 2. Run on Web Browser  
echo 3. Build Windows Release
echo 4. Build Web Release
echo 5. Run Flutter analyze
echo.

set /p choice="Enter your choice (1-5): "

if "%choice%"=="1" (
    echo.
    echo Running on Windows...
    flutter run -d windows
) else if "%choice%"=="2" (
    echo.
    echo Running on Web...
    flutter run -d chrome
) else if "%choice%"=="3" (
    echo.
    echo Building Windows Release...
    flutter build windows --release
    echo.
    echo Build completed! Check: build\windows\x64\runner\Release\
    pause
) else if "%choice%"=="4" (
    echo.
    echo Building Web Release...
    flutter build web --release
    echo.
    echo Build completed! Check: build\web\
    pause
) else if "%choice%"=="5" (
    echo.
    echo Running Flutter analyze...
    flutter analyze
    echo.
    pause
) else (
    echo Invalid choice!
    pause
)
