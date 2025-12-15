@echo off
echo ========================================
echo TOOTH DETECTION API - STARTUP SCRIPT
echo ========================================
echo.

echo Checking Python installation...
python --version
if %errorlevel% neq 0 (
    echo ERROR: Python not found!
    echo Please install Python 3.11+ from https://www.python.org/
    pause
    exit /b 1
)

echo.
echo Checking dependencies...
pip show flask >nul 2>&1
if %errorlevel% neq 0 (
    echo Installing dependencies...
    pip install -r requirements.txt
) else (
    echo Dependencies already installed!
)

echo.
echo ========================================
echo STARTING API SERVER
echo ========================================
echo.
echo Server will start at: http://localhost:5000
echo.
echo API Health Check: http://localhost:5000/api/health
echo Frontend Test UI: Open frontend\index.html in browser
echo.
echo Press Ctrl+C to stop the server
echo ========================================
echo.

cd api
python api.py

pause
