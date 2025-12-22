# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Fast and customizable system information tool written in C++"
HOMEPAGE="https://github.com/username/linuxfetch"
SRC_URI="https://github.com/username/linuxfetch/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
    sys-libs/ncurses
    sys-apps/pciutils
"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${P}"

src_compile() {
    cmake_src_compile
}

src_install() {
    dobin "${BUILD_DIR}/linuxfetch"
    dodoc README.md
}
