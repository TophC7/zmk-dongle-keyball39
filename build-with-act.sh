#!/usr/bin/env bash

# Build Keyball39 firmware using GitHub Actions locally with act
set -e

echo "================================================"
echo "    Keyball39 Firmware Builder (using act)"
echo "================================================"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if act is available
if ! command -v act &> /dev/null; then
    echo -e "${RED}Error: 'act' is not installed${NC}"
    echo "Enter nix-shell first: nix-shell"
    exit 1
fi

echo -e "${YELLOW}Forcing use of full Ubuntu image with all tools...${NC}"
echo "This image is large (~12GB) but includes yq and all other required tools"
echo ""

# Force the full image for ALL platforms to ensure yq is available
# The node image doesn't have yq which is required by the ZMK workflow
ACT_COMMAND="act"
ACT_FLAGS=(
    "workflow_dispatch"  # Use workflow_dispatch event instead of push
    "-j" "build"
    "-P" "ubuntu-latest=catthehacker/ubuntu:full-latest"
    "-P" "ubuntu-22.04=catthehacker/ubuntu:full-22.04"
    "-P" "ubuntu-20.04=catthehacker/ubuntu:full-20.04"
    "--container-architecture" "linux/amd64"
    "--pull=true"  # Force pull the latest image
    "--rm"
    "-v"
)

echo -e "${YELLOW}Running: act ${ACT_FLAGS[*]}${NC}"
echo ""

# Run the GitHub Actions workflow with explicit full image
if $ACT_COMMAND "${ACT_FLAGS[@]}"; then
    echo -e "\n${GREEN}✓ Build completed successfully!${NC}"

    # Check if artifacts were created
    if [ -d ".act-artifacts" ]; then
        echo -e "${GREEN}Firmware files should be in .act-artifacts/${NC}"
        ls -la .act-artifacts/ 2>/dev/null || true
    fi

    echo -e "\n${YELLOW}To flash your keyboard:${NC}"
    echo "1. Put the nice!nano into bootloader mode (double-tap reset)"
    echo "2. Copy the appropriate .uf2 file to the mounted drive"
    echo "   - Left side:  keyball39_left nice_nano_v2.uf2"
    echo "   - Right side: keyball39_right nice_nano_v2.uf2"
else
    echo -e "${RED}✗ Build failed${NC}"
    echo "Check the output above for errors"
    exit 1
fi