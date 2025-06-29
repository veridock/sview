#!/bin/bash
# Script to create distribution packages for SView

set -e

# Source common functions and variables
source "$(dirname "$0")/common.sh"

create_package() {
    log_info "📦 Creating distribution packages..."
    
    # Ensure we have a release build
    if [ ! -f "${TARGET_DIR}/release/${PROJECT_NAME}" ]; then
        log_error "No release build found. Run 'make release' first."
        exit 1
    fi
    
    # Create distribution directory structure
    mkdir -p "${DIST_DIR}/deb/DEBIAN"
    mkdir -p "${DIST_DIR}/deb/usr/local/bin"
    mkdir -p "${DIST_DIR}/deb/usr/share/applications"
    mkdir -p "${DIST_DIR}/deb/usr/share/icons/hicolor/scalable/apps"

    # Copy binary
    cp "${TARGET_DIR}/release/${PROJECT_NAME}" "${DIST_DIR}/deb/usr/local/bin/"

    # Create .desktop file
    cat > "${DIST_DIR}/deb/usr/share/applications/${PROJECT_NAME}.desktop" << EOF
[Desktop Entry]
Name=SView
Comment=SVG Viewer & PWA Launcher
Exec=${PROJECT_NAME} %f
Icon=${PROJECT_NAME}
Terminal=false
Type=Application
Categories=Graphics;Viewer;
EOF

    # Copy icon if it exists
    if [ -f "assets/icon.svg" ]; then
        mkdir -p "${DIST_DIR}/deb/usr/share/icons/hicolor/scalable/apps"
        cp "assets/icon.svg" "${DIST_DIR}/deb/usr/share/icons/hicolor/scalable/apps/${PROJECT_NAME}.svg"
    fi

    # Create DEBIAN/control
    cat > "${DIST_DIR}/deb/DEBIAN/control" << EOF
Package: ${PROJECT_NAME}
Version: ${VERSION}
Section: graphics
Priority: optional
Architecture: amd64
Maintainer: Your Name <your.email@example.com>
Description: SVG Viewer & PWA Launcher
EOF

    # Build .deb package
    dpkg-deb --build "${DIST_DIR}/deb" "${DIST_DIR}/${PROJECT_NAME}_${VERSION}_amd64.deb"

    # Create tarball
    mkdir -p "${DIST_DIR}/package"
    cp "${TARGET_DIR}/release/${PROJECT_NAME}" "${DIST_DIR}/package/"
    if [ -d "${GUI_DIR}/dist" ]; then
        cp -r "${GUI_DIR}/dist" "${DIST_DIR}/package/gui"
    fi
    
    tar -czf "${DIST_DIR}/${PROJECT_NAME}_${VERSION}_linux_amd64.tar.gz" -C "${DIST_DIR}/package" .
    
    log_success "✅ Distribution packages created in ${DIST_DIR}"
    log_info "  - Debian package: ${DIST_DIR}/${PROJECT_NAME}_${VERSION}_amd64.deb"
    log_info "  - Tarball: ${DIST_DIR}/${PROJECT_NAME}_${VERSION}_linux_amd64.tar.gz"
}

# Main execution
create_package
