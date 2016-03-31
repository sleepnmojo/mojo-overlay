# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI="3"
PYTHON_DEPEND="2:2.7"
inherit eutils multilib python

MY_P="$P"
MY_P="${MY_P/sab/SAB}"
MY_P="${MY_P/_beta/Beta}"
MY_P="${MY_P/_rc/RC}"


DESCRIPTION="Binary Newsgrabber written in Python, server-oriented using a web-interface.The active successor of the abandoned SABnzbd project."
HOMEPAGE="http://www.sabnzbd.org/"
SRC_URI="mirror://sourceforge/sabnzbdplus/${MY_P}-src.tar.gz"

HOMEDIR="${ROOT}var/lib/${PN}"
DHOMEDIR="/var/lib/${PN}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+rar unzip +yenc ssl logrotate"

RDEPEND="
		>=dev-lang/python-2.7
		>=dev-python/celementtree-1.0.5
		>=dev-python/cheetah-2.0.1
		>=app-arch/par2cmdline-0.4
		rar? ( || ( app-arch/unrar app-arch/rar ) )
		unzip? ( app-arch/unzip )
		yenc? ( >=dev-python/yenc-0.3 )
		ssl? ( dev-python/pyopenssl )"
DEPEND="${RDEPEND}
		app-text/dos2unix
		logrotate? ( app-admin/logrotate )"

S="${WORKDIR}/${MY_P}"
DOCS=( "CHANGELOG.txt" "ISSUES.txt" "INSTALL.txt" "README.txt"
"Sample-PostProc.sh" "licences/*" )

pkg_setup() {
	#Create group and user
	enewgroup "${PN}"
	enewuser "${PN}" -1 -1 "${HOMEDIR}" "${PN}"

	python_set_active_version 2
}

get_key() {
	local mypy len
	len=24
	mypy="import string;"
	mypy="$mypy from random import Random;"
	mypy="$mypy print ''.join(Random().sample(string.letters+string.digits, $len));"
	python -c "$mypy"
}

src_install() {
	api_key=$(get_key)
	ewarn "Setting api key to: $api_key"

	#Init scripts
	newconfd "${FILESDIR}/${PN}.conf" "${PN}"
	newinitd "${FILESDIR}/${PN}.init" "${PN}"

	#Example config
	cd "${S}"
	cp  "${FILESDIR}/${PN}.ini" .
	sed -e "s/%API_KEY%/$api_key/g" -i "${PN}.ini"
	insinto /etc/${PN}
	newins "${PN}.ini" "${PN}.conf"
	fowners -R ${PN}:${PN} /etc/${PN}
	fperms -R ug=rwX /etc/${PN}

	if use logrotate; then
		# Rotation of logfile
		insinto /etc/logrotate.d
		newins "${FILESDIR}/${PN}.logrotate" ${PN}
	fi

	#Create all default dirs
	keepdir ${DHOMEDIR}

	for i in download dirscan complete nzb_backup cache scripts admin;do
		keepdir ${DHOMEDIR}/${i}
	done
	fowners -R ${PN}:${PN} ${DHOMEDIR}
	fperms -R =rX,ug+w ${DHOMEDIR}

	for i in log cache run ;do
		keepdir /var/${i}/${PN}
		fowners -R ${PN}:${PN} /var/${i}/${PN}
		fperms -R =rX,ug+w /var/${i}/${PN}
	done

	#Add themes & code
	dodir /usr/share/${PN}
	insinto /usr/share/${PN}
	for sab_dir in cherrypy email gntp icons interfaces ${PN} locale tools util ; do
		doins -r ${sab_dir} || die "failed to install ${sab_dir}"
	done
	doins SABnzbd.py || die "installing SABnzbd.py"

	#fix permissions
	fowners -R ${PN}:${PN} /usr/share/${PN}
	fperms -R =rX,ug+w /usr/share/${PN}
}

pkg_postinst() {

	# optimizing
	python_mod_optimize "/usr/share/${PN}"

	einfo "Default directory: ${HOMEDIR}"
	einfo ""
	einfo "Run: gpasswd -a <user> ${PN}"
	einfo "to add an user to the sabnzbd group so it can edit sabnzbd files"
	einfo ""
	ewarn "Please configure /etc/conf.d/${PN} before starting!"
	einfo ""
	einfo "Start with ${ROOT}etc/init.d/${PN} start"
	einfo "Default web credentials : sabnzbd/secret"
	einfo ""
	ewarn "When upgrading ${PN}, don't forget to fix the permissions"
	ewarn "on the config file after merging the changes."
	ewarn ""
	ewarn "chown -cvR ${PN}:${PN} /etc/${PN} && chmod -cvR 660 /etc/${PN}"
}
