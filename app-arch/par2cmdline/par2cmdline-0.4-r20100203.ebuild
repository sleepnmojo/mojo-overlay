# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI=4
inherit eutils autotools

MY_PR="${PR/r/}"

DESCRIPTION="This is a concurrent (multithreaded) version of par2cmdline 0.4, a utility to create and repair data files using Reed Solomon coding."
HOMEPAGE="http://chuchusoft.com/par2_tbb/index.html"
SRC_URI="http://chuchusoft.com/par2_tbb/${PN}-${PV}-tbb-${MY_PR}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-cpp/tbb"

DOCS="AUTHORS ChangeLog README"

S=${WORKDIR}/${PN}-${PV}-tbb-${MY_PR}

src_prepare() {
	epatch \
		"${FILESDIR}"/${PN}-${PV}-tbb-compile.patch
	
	eautoreconf
}

src_install() {
	default
	# Replace the hardlinks with symlinks
	dosym par2 /usr/bin/par2create
	dosym par2 /usr/bin/par2repair
	dosym par2 /usr/bin/par2verify
}
