#!/bin/bash

# Ease App - Release Build Script
# Builds production-ready APK

echo "🌿 Building Ease App for Release"
echo "================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Step 1: Clean
echo "1️⃣  Cleaning previous builds..."
flutter clean
echo ""

# Step 2: Get dependencies
echo "2️⃣  Installing dependencies..."
flutter pub get
echo ""

# Step 3: Build APK
echo "3️⃣  Building release APK..."
flutter build apk --release

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Build successful!${NC}"
    echo ""
    echo "📦 APK Location:"
    echo "   build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    
    # Get file size
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        SIZE=$(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)
        echo "📊 APK Size: $SIZE"
        echo ""
    fi
    
    echo "🚀 Next steps:"
    echo "   1. Test the APK on a device"
    echo "   2. Install: adb install build/app/outputs/flutter-apk/app-release.apk"
    echo "   3. Or share the APK file directly"
    echo ""
else
    echo ""
    echo -e "${RED}❌ Build failed${NC}"
    echo "Check errors above and try again"
    exit 1
fi
