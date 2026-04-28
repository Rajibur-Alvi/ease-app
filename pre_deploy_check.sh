#!/bin/bash

# Ease App - Pre-Deployment Checklist
# Run this before building release APK

echo "🌿 Ease App - Pre-Deployment Check"
echo "===================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0

# 1. Check Flutter installation
echo "1️⃣  Checking Flutter installation..."
if command -v flutter &> /dev/null; then
    echo -e "${GREEN}✓${NC} Flutter found"
    flutter --version | head -n 1
else
    echo -e "${RED}✗${NC} Flutter not found"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# 2. Run flutter doctor
echo "2️⃣  Running flutter doctor..."
flutter doctor
echo ""

# 3. Clean previous builds
echo "3️⃣  Cleaning previous builds..."
flutter clean
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Clean successful"
else
    echo -e "${RED}✗${NC} Clean failed"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# 4. Get dependencies
echo "4️⃣  Getting dependencies..."
flutter pub get
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Dependencies installed"
else
    echo -e "${RED}✗${NC} Dependency installation failed"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# 5. Run code analysis
echo "5️⃣  Running code analysis..."
flutter analyze --no-fatal-infos
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} No errors found"
else
    echo -e "${YELLOW}⚠${NC} Analysis warnings found (review above)"
fi
echo ""

# 6. Run tests
echo "6️⃣  Running tests..."
flutter test
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} All tests passed"
else
    echo -e "${RED}✗${NC} Tests failed"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# 7. Check for TODOs
echo "7️⃣  Checking for unresolved TODOs..."
TODO_COUNT=$(grep -r "TODO" lib/ | wc -l)
if [ $TODO_COUNT -gt 0 ]; then
    echo -e "${YELLOW}⚠${NC} Found $TODO_COUNT TODO comments"
    grep -r "TODO" lib/ | head -n 5
else
    echo -e "${GREEN}✓${NC} No TODOs found"
fi
echo ""

# 8. Check assets directory
echo "8️⃣  Checking assets..."
if [ -d "assets/images" ]; then
    echo -e "${GREEN}✓${NC} Assets directory exists"
else
    echo -e "${YELLOW}⚠${NC} Assets directory missing (creating...)"
    mkdir -p assets/images
fi
echo ""

# 9. Verify pubspec.yaml
echo "9️⃣  Verifying pubspec.yaml..."
if grep -q "version:" pubspec.yaml; then
    VERSION=$(grep "version:" pubspec.yaml | awk '{print $2}')
    echo -e "${GREEN}✓${NC} App version: $VERSION"
else
    echo -e "${RED}✗${NC} Version not found in pubspec.yaml"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# 10. Check for hardcoded secrets
echo "🔟 Checking for hardcoded secrets..."
SECRET_PATTERNS=("password" "api_key" "secret" "token")
FOUND_SECRETS=0
for pattern in "${SECRET_PATTERNS[@]}"; do
    if grep -ri "$pattern" lib/ | grep -v "// " | grep -v "password)" > /dev/null; then
        FOUND_SECRETS=$((FOUND_SECRETS + 1))
    fi
done
if [ $FOUND_SECRETS -eq 0 ]; then
    echo -e "${GREEN}✓${NC} No hardcoded secrets found"
else
    echo -e "${YELLOW}⚠${NC} Potential secrets found (review manually)"
fi
echo ""

# Summary
echo "===================================="
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ All checks passed!${NC}"
    echo ""
    echo "Ready to build:"
    echo "  flutter build apk --release"
    echo ""
else
    echo -e "${RED}❌ $ERRORS error(s) found${NC}"
    echo "Fix errors before deploying"
    exit 1
fi
