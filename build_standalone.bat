@echo off
REM Script to build a standalone executable that serves the Flutter web app

echo Building OBS Blade standalone server...
echo.

REM Step 1: Build Flutter web app
echo Step 1/4: Building Flutter web app...
call flutter build web --release
if %errorlevel% neq 0 exit /b %errorlevel%
echo [32m✓ Flutter web build complete[0m
echo.

REM Step 2: Get dependencies for server
echo Step 2/4: Getting server dependencies...
cd server
call dart pub get
if %errorlevel% neq 0 exit /b %errorlevel%
cd ..
echo [32m✓ Server dependencies installed[0m
echo.

REM Step 3: Compile server to executable
echo Step 3/4: Compiling server to executable...
cd server
call dart compile exe server.dart -o ../dist/obs_blade_server.exe
if %errorlevel% neq 0 exit /b %errorlevel%
cd ..
echo [32m✓ Server compiled[0m
echo.

REM Step 4: Copy web files to dist
echo Step 4/4: Copying web files...
if not exist dist mkdir dist
if not exist dist\web mkdir dist\web
xcopy /E /I /Y build\web dist\web
echo [32m✓ Web files copied[0m
echo.

echo ==========================================
echo Build complete!
echo.
echo Files are in the 'dist' folder:
echo   - obs_blade_server.exe (executable)
echo   - web\ (Flutter web app files)
echo.
echo To run the server:
echo   cd dist
echo   obs_blade_server.exe [port]
echo.
echo Default port is 8080
echo Example: obs_blade_server.exe 3000
echo ==========================================
pause
