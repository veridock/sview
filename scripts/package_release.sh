#!/bin/bash
# Script to package SView for distribution

set -e

# Source common functions and variables
source "$(dirname "$0")/common.sh"

log_info "📦 Creating distribution packages..."

# Create Linux tarball
log_info "Creating Linux tarball..."
tar -czf "${DIST_DIR}/${PROJECT_NAME}-${VERSION}-linux-x86_64.tar.gz" -C "${DIST_DIR}" .

# Create .deb package structure
log_info "Creating .deb package..."
DEB_DIR="${DIST_DIR}/deb/${PROJECT_NAME}_${VERSION}"
mkdir -p "${DEB_DIR}/DEBIAN"
mkdir -p "${DEB_DIR}/usr/bin"
mkdir -p "${DEB_DIR}/usr/share/applications"
mkdir -p "${DEB_DIR}/usr/share/doc/${PROJECT_NAME}"

# Create control file
cat > "${DEB_DIR}/DEBIAN/control" <<EOF
Package: ${PROJECT_NAME}
Version: ${VERSION}
Section: utils
Priority: optional
Architecture: amd64
Maintainer: sView Team <info@softreck.dev>
Description: SVG Viewer & PWA Launcher with sView Integration
 SView is an advanced tool for managing, viewing and running SVG files
 as PWA applications with sView memory system integration.
EOF

# Copy files to .deb structure
cp "${DIST_DIR}/${PROJECT_NAME}" "${DEB_DIR}/usr/bin/"
cp "${PROJECT_ROOT}/README.md" "${DEB_DIR}/usr/share/doc/${PROJECT_NAME}/"
cp "${PROJECT_ROOT}/LICENSE" "${DEB_DIR}/usr/share/doc/${PROJECT_NAME}/"

# Build .deb package
if command -v dpkg-deb >/dev/null 2>&1; then
    dpkg-deb --build "${DEB_DIR}" >/dev/null
    mv "${DIST_DIR}/deb/${PROJECT_NAME}_${VERSION}.deb" "${DIST_DIR}/"
    log_success "✅ .deb package created"
else
    log_warning "⚠️  dpkg-deb not found - skipping .deb package"
fi

# Create AppImage (Linux)
if command -v appimagetool >/dev/null 2>&1; then
    log_info "Creating AppImage..."
    APPIMAGE_DIR="${DIST_DIR}/appimage/${PROJECT_NAME}.AppDir"
    mkdir -p "${APPIMAGE_DIR}/usr/bin"
    
    # Copy binary
    cp "${DIST_DIR}/${PROJECT_NAME}" "${APPIMAGE_DIR}/usr/bin/"
    
    # Create desktop file
    cat > "${APPIMAGE_DIR}/${PROJECT_NAME}.desktop" <<EOF
[Desktop Entry]
Name=SView
Exec=${PROJECT_NAME}
Icon=${PROJECT_NAME}
Type=Application
Categories=Utility;
EOF
    
    # Create AppRun
    cat > "${APPIMAGE_DIR}/AppRun" <<EOF
#!/bin/sh
HERE="\$(dirname "\$(readlink -f "\$0")")"
exec "\${HERE}/usr/bin/${PROJECT_NAME}" "\$@"
EOF
    chmod +x "${APPIMAGE_DIR}/AppRun"
    
    # Build AppImage
    appimagetool "${APPIMAGE_DIR}" "${DIST_DIR}/${PROJECT_NAME}-${VERSION}-x86_64.AppImage" >/dev/null
    log_success "✅ AppImage created"
else
    log_warning "⚠️  appimagetool not found - skipping AppImage"
fi

log_success "✅ Distribution packages created"
echo ""
