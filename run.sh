#!/bin/bash
# Quick Start Script for Sign Language Detection
# This script helps set up and run the application

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║   🤟 Sign Language Detection - Quick Start Guide        ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Step 1: Check Python
echo -e "${BLUE}Step 1: Checking Python Version${NC}"
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo -e "${GREEN}✓ Found: $PYTHON_VERSION${NC}"
    PYTHON_CMD="python3"
else
    echo -e "${RED}✗ Python 3 not found. Please install Python 3.8+${NC}"
    exit 1
fi

# Step 2: Create virtual environment (optional but recommended)
echo ""
echo -e "${BLUE}Step 2: Setting up Virtual Environment (recommended)${NC}"
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    $PYTHON_CMD -m venv venv
    echo -e "${GREEN}✓ Virtual environment created${NC}"
else
    echo -e "${GREEN}✓ Virtual environment already exists${NC}"
fi

# Activate virtual environment
if [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
    echo -e "${GREEN}✓ Virtual environment activated${NC}"
elif [ -f "venv/Scripts/activate" ]; then
    source venv/Scripts/activate
    echo -e "${GREEN}✓ Virtual environment activated${NC}"
fi

# Step 3: Install requirements
echo ""
echo -e "${BLUE}Step 3: Installing Dependencies${NC}"
if [ -f "requirements.txt" ]; then
    echo "Installing packages from requirements.txt..."
    pip install --upgrade pip
    pip install -r requirements.txt
    echo -e "${GREEN}✓ Dependencies installed${NC}"
else
    echo -e "${RED}✗ requirements.txt not found${NC}"
    exit 1
fi

# Step 4: Verify setup
echo ""
echo -e "${BLUE}Step 4: Verifying Setup${NC}"
$PYTHON_CMD setup_verify.py

# Step 5: Launch app
echo ""
echo -e "${BLUE}Step 5: Launching Application${NC}"
echo ""
echo -e "${YELLOW}Opening Streamlit at: http://localhost:8501${NC}"
echo ""
echo -e "${GREEN}Starting Sign Language Detection System...${NC}"
echo ""

# Run the main app
streamlit run app.py --logger.level=error

# Note: Script will continue to run while streamlit is active
# Press Ctrl+C to stop
