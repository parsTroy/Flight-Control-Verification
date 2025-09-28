#!/bin/bash

# Manual GitHub Pages Deployment Script
# This script provides an alternative deployment method if GitHub Actions fails

echo "=== Flight Control Verification - Manual Deployment ==="

# Check if we're in the right directory
if [ ! -d "web" ]; then
    echo "Error: Please run this script from the Flight-Control-Verification directory"
    exit 1
fi

# Create build directory
echo "Creating build directory..."
rm -rf build
mkdir -p build

# Copy web files
echo "Copying web files..."
cp -r web/* build/

# Copy documentation
echo "Copying documentation..."
mkdir -p build/docs
cp -r web/docs/* build/docs/

# Copy MATLAB files for reference
echo "Copying MATLAB files..."
mkdir -p build/matlab
cp -r matlab/* build/matlab/

# Copy requirements and config
echo "Copying configuration files..."
cp requirements/* build/ 2>/dev/null || true
cp config/* build/ 2>/dev/null || true

# Create a simple index if needed
if [ ! -f build/index.html ]; then
    echo "Creating index.html..."
    cp web/index.html build/
fi

# Create .nojekyll file to bypass Jekyll processing
echo "Creating .nojekyll file..."
touch build/.nojekyll

echo "Build completed successfully!"
echo ""
echo "To deploy manually:"
echo "1. Create a 'gh-pages' branch: git checkout -b gh-pages"
echo "2. Copy build contents to root: cp -r build/* ."
echo "3. Add and commit: git add . && git commit -m 'Deploy to GitHub Pages'"
echo "4. Push: git push origin gh-pages"
echo "5. Enable GitHub Pages in repository settings"
echo ""
echo "Or use the build directory with any static hosting service:"
echo "- Netlify: Drag and drop the build folder"
echo "- Vercel: Connect your repository"
echo "- GitHub Pages: Upload build contents to gh-pages branch"
echo ""
echo "Build directory ready: ./build/"
