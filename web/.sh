#!/bin/bash

# Function to ensure a directory is in PATH
ensure_in_path() {
    if [[ ":$PATH:" != *":$1:"* ]]; then
        export PATH="$1:$PATH"
    fi
}

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
    OS="windows"
else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

# Install Python if not available
if ! command -v python3 &> /dev/null; then
    echo "Installing Python 3..."
    if [[ "$OS" == "linux" ]]; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y python3 python3-pip
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y python3 python3-pip
        elif command -v yum &> /dev/null; then
            sudo yum install -y python3 python3-pip
        else
            echo "Unsupported Linux distribution. Please install Python 3 manually."
            exit 1
        fi
    elif [[ "$OS" == "macos" ]]; then
        if command -v brew &> /dev/null; then
            brew install python
        else
            echo "Homebrew not found. Please install Homebrew or Python 3 manually."
            exit 1
        fi
    elif [[ "$OS" == "windows" ]]; then
        echo "Please install Python 3 from https://www.python.org/downloads/"
        echo "Make sure to check 'Add Python to PATH' during installation."
        exit 1
    fi
fi

# Set up Python user bin directory based on OS
if [[ "$OS" == "windows" ]]; then
    PYTHON_USER_BASE=$(python3 -m site --user-base)
    PYTHON_BIN_DIR="${PYTHON_USER_BASE}/Scripts"
    ARPIT_EXEC="arpit.exe"
else
    # For Linux and macOS
    if [ -d "$HOME/.local/bin" ]; then
        PATH="$HOME/.local/bin:$PATH"
    fi
    PYTHON_USER_BASE=$(python3 -m site --user-base)
    PYTHON_BIN_DIR="${PYTHON_USER_BASE}/bin"
    ARPIT_EXEC="arpit"
fi

ensure_in_path "$PYTHON_BIN_DIR"

# Install pip if not available
if ! command -v pip3 &> /dev/null; then
    echo "Installing pip..."
    python3 -m ensurepip --upgrade
fi

# Install arpit package
echo "Installing arpit package..."
pip3 install --user git+https://github.com/arpy8/arpit

# Check if arpit is installed and executable
if ! command -v arpit &> /dev/null; then
    echo "Error: arpit was not installed correctly or is not in PATH."
    echo "Trying to find arpit in Python bin directory..."
    
    if [ -f "$PYTHON_BIN_DIR/$ARPIT_EXEC" ]; then
        echo "Found arpit at $PYTHON_BIN_DIR/$ARPIT_EXEC"
        if [[ "$OS" != "windows" ]]; then
            chmod +x "$PYTHON_BIN_DIR/$ARPIT_EXEC"
        fi
        ensure_in_path "$PYTHON_BIN_DIR"
    else
        echo "Could not find arpit. Installation may have failed."
        exit 1
    fi
fi

# Run arpit
echo "Running arpit..."
arpit || {
    echo "Error: Failed to run 'arpit'. Trying with full path..."
    "$PYTHON_BIN_DIR/$ARPIT_EXEC"
}
