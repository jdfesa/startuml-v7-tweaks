#!/bin/bash

echo "========================================="
echo "StarUML v7.0.0 License Validation PoC (Mac/Linux)"
echo "========================================="

# Check for sudo/root
if [ "$EUID" -ne 0 ]; then
  echo "[ERROR] Please run this script with sudo:"
  echo "sudo ./patch.sh"
  exit 1
fi

# Check for npm
if ! command -v npm &> /dev/null; then
    echo "[ERROR] npm is not installed. Please install Node.js."
    exit 1
fi

echo "[INFO] Installing asar globally..."
npm i asar -g

# Determine OS and set StarUML path
if [[ "$OSTYPE" == "darwin"* ]]; then
    STARUML_DIR="/Applications/StarUML.app/Contents/Resources"
else
    STARUML_DIR="/opt/staruml/resources"
fi

if [ ! -f "$STARUML_DIR/app.asar" ]; then
    echo "[ERROR] Could not find StarUML installation at $STARUML_DIR"
    exit 1
fi

# Store the path where the script is located
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo "[INFO] Moving to $STARUML_DIR"
cd "$STARUML_DIR" || exit

echo "[INFO] Extracting app.asar..."
asar e app.asar app

echo "[INFO] Copying modified files..."
cp -f "$SCRIPT_DIR/app/src/engine/license-store.js" "app/src/engine/license-store.js"
cp -f "$SCRIPT_DIR/app/src/engine/diagram-export.js" "app/src/engine/diagram-export.js"
cp -f "$SCRIPT_DIR/app/src/dialogs/license-activation-dialog.js" "app/src/dialogs/license-activation-dialog.js"

echo "[INFO] Repacking app.asar..."
asar pack app app.asar

echo "[INFO] Cleaning up..."
rm -rf app

echo "[SUCCESS] PoC deployed successfully! (For educational testing only)"
