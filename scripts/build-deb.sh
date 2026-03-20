#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause
# Copyright 2024-2025 <Nitrux Latinoamericana S.C. <hello@nxos.org>>


# -- Exit on errors.

set -e


# -- Download Source

git clone --depth 1 --branch "$FIERY_BRANCH" https://github.com/Nitrux/maui-fiery.git


# -- Compile Source

mkdir -p build && cd build

HOST_MULTIARCH=$(dpkg-architecture -qDEB_HOST_MULTIARCH)

cmake \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DENABLE_BSYMBOLICFUNCTIONS=OFF \
	-DQUICK_COMPILER=ON \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_SYSCONFDIR=/etc \
	-DCMAKE_INSTALL_LOCALSTATEDIR=/var \
	-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON \
	-DCMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=ON \
	-DCMAKE_INSTALL_RUNSTATEDIR=/run "-GUnix Makefiles" \
	-DCMAKE_VERBOSE_MAKEFILE=ON \
	-DCMAKE_INSTALL_LIBDIR="/usr/lib/${HOST_MULTIARCH}" \
	../maui-fiery/

make -j"$(nproc)"

make install


# -- Run checkinstall and Build Debian Package

>> description-pak printf "%s\n" \
	'MauiKit convergent web browser.' \
	'' \
	'Fiery allows you to browse the web.' \
	'' \
	'Fiery works on desktops, Android and Plasma Mobile.' \
	'' \
	''

checkinstall -D -y \
	--install=no \
	--fstrans=yes \
	--pkgname=fiery \
	--pkgversion="$PACKAGE_VERSION" \
	--pkgarch="$(dpkg --print-architecture)" \
	--pkgrelease="1" \
	--pkglicense=LGPL-3 \
	--pkggroup=lib \
	--pkgsource=fiery \
	--pakdir=. \
	--maintainer=uri_herrera@nxos.org \
	--provides=fiery \
	--requires="gir1.2-secret-1,kio-extras,libqt6pdf6,libqt6pdfquick6,libqt6pdfwidgets6,libqt6webenginecore6,libqt6webenginecore6-bin,libqt6webenginequick6,libqt6webenginewidgets6,libsecret-1-0,mauikit \(\>= 4.0.2\),mauikit-filebrowsing \(\>= 4.0.2\),qml6-module-qtcore,qml6-module-qtquick-effects,qml6-module-qtquick-pdf,qml6-module-qtwebengine,qml6-module-qtwebengine-controlsdelegates" \
	--nodoc \
	--strip=no \
	--stripso=yes \
	--reset-uids=yes \
	--deldesc=yes
