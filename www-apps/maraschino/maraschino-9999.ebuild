# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI="3"
PYTHON_DEPEND="2:2.7"
inherit eutils multilib python git-2

DESCRIPTION="web frontend for sabnzbd, couchpotato, sickbeard, headphones, andxbmc"
HOMEPAGE="http://www.maraschinoproject.com/"
SRC_URI=""

EGIT_REPO_URI="git://github.com/mrkipling/maraschino.git"

HOMEDIR="${ROOT}usr/share/${PN}"
EGIT_SOURCEDIR="${HOMEDIR}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="logrotate"

RDEPEND="
		>=dev-lang/python-2.7
		>=dev-python/pysqlite-2.3"
DEPEND="${RDEPEND}
		logrotate? ( app-admin/logrotate )"

pkg_setup() {
    	#Create group and user
    	enewgroup "${PN}"
    	enewuser "${PN}" -1 -1 "${HOMEDIR}" "${PN}"

    	python_set_active_version 2
}

src_install() {
	#Init scripts
	newconfd "${FILESDIR}/${PN}.conf" "${PN}"
	newinitd "${FILESDIR}/${PN}.init" "${PN}"

	for i in log cache run lib; do
		keepdir /var/${i}/${PN}
		fowners -R maraschino:maraschino /var/${i}/${PN}
		fperms -R =rX,ug+w /var/${i}/${PN}
	done

	if use logrotate; then
		# Rotation of logfile
		insinto /etc/logrotate.d
		newins "${FILESDIR}/${PN}.logrotate" ${PN}
	fi

	#Create all default dirs
	keepdir ${HOMEDIR}
	dosym /var/log/${PN} ${HOMEDIR}/logs
	dosym /var/cache/${PN} ${HOMEDIR}/cache
	fowners -R maraschino:maraschino ${HOMEDIR}
	fperms -R =rX,ug+w ${HOMEDIR}
}

pkg_postinst() {

	# optimizing
	python_mod_optimize "${HOMEDIR}"

	einfo "Default directory: ${HOMEDIR}"
	einfo ""
	einfo "New user/group ${PN}/${PN} has been created"
	einfo ""
	einfo "Please configure ${ROOT}etc/conf.d/${PN} before starting as daemon!"
	einfo "Port setting in ${ROOT}etc/conf.d/${PN} has priority over the port set in webinterface"
	einfo ""
	einfo "Start with ${ROOT}etc/init.d/${PN} start"
	einfo "Visit http://<host ip>:7000 to configure Maraschino"
	einfo ""
	einfo "Security note:"
	einfo "There is no default username/password, so it is important that you configure maraschino using the web interface!"
}
