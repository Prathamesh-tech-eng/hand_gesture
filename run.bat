@echo off
REM Quick Start Script for Sign Language Detection (Windows)
REM This script helps set up and run the application

echo.
echo ╔══════════════════════════════════════════════════════════╗
echo.║   🤟 Sign Language Detection - Quick Start Guide        ║
echo ╚══════════════════════════════════════════════════════════╝
echo.

REM Check Python
echo Step 1: Checking Python Version
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ✗ Python not found. Please install Python 3.8+
    echo   Download from: https://www.python.org/downloads/
    pause
    exit /b 1
)
python --version
echo ✓ Python found
echo.

REM Create virtual environment
echo Step 2: Setting up Virtual Environment
if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
    echo ✓ Virtual environment created
) else (
    echo ✓ Virtual environment already exists
)
echo.

REM Activate virtual environment
echo Step 3: Activating Virtual Environment
call venv\Scripts\activate.bat
echo ✓ Virtual environment activated
echo.

REM Install requirements
echo Step 4: Installing Dependencies
if exist "requirements.txt" (
    echo Installing packages from requirements.txt...
    python -m pip install --upgrade pip
    pip install -r requirements.txt
    echo ✓ Dependencies installed
) else (
    echo ✗ requirements.txt not found
    pause
    exit /b 1
)
echo.

REM Verify setup
echo Step 5: Verifying Setup
python setup_verify.py
echo.

REM Check if model exists
if not exist "tms_isl_final_int8.tflite" (
    echo.
    echo ⚠️  WARNING: Model file not found!
    echo     File: tms_isl_final_int8.tflite
    echo.
    echo     The application will crash when you try to run it.
    echo     Please ensure the model file is in this directory.
    echo.
    pause
)

REM Launch app
echo.
echo Step 6: Launching Application
echo.
echo ✓ Opening Streamlit at: http://localhost:8501
echo.
echo Starting Sign Language Detection System...
echo.
echo (Press Ctrl+C to stop the application)
echo.

start http://localhost:8501
timeout /t 2 /nobreak
streamlit run app.py --logger.level=error

pause
