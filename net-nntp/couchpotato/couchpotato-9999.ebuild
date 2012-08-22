# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI="3"
PYTHON_DEPEND="2:2.7"
inherit eutils multilib python git

MY_PN="$PN"
MY_PN="${MY_PN/c/C}"
MY_PN="${MY_PN/p/P}"

DESCRIPTION="CouchPotato (CP) is an automatic NZB and torrent downloader. You can keep a \"movies I want\"-list and it will search for NZBs/torrents of these movies every X hours. Once a movie is found, it will send it to SABnzbd or download the torrent to a specified directory."
HOMEPAGE="http://couchpota.to/"
SRC_URI=""

EGIT_REPO_URI="git://github.com/RuudBurger/${MY_PN}Server.git"

HOMEDIR="${ROOT}var/lib/${PN}"
DHOMEDIR="/var/lib/${PN}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="rss ssl logrotate "

RDEPEND="
		>=dev-lang/python-2.7
		>=dev-python/pysqlite-2.3
		rss? ( dev-python/feedparser )
		ssl? ( dev-python/pyopenssl )"
DEPEND="${RDEPEND}
		net-nntp/sabnzbd
		logrotate? ( app-admin/logrotate )"

DOCS=( "license.txt" "README.md" )

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
	insinto /etc/sabnzbd/
	newins "${PN}.ini" "${PN}.conf"
	fowners -R sabnzbd:sabnzbd /etc/sabnzbd
	fperms -R ug=rwX /etc/sabnzbd

	if use logrotate; then
		# Rotation of logfile
		insinto /etc/logrotate.d
		newins "${FILESDIR}/${PN}.logrotate" ${PN}
	fi

	for c_dir in log cache ; do
		keepdir /var/${c_dir}/${PN}
	    fowners -R sabnzbd:sabnzbd /var/${c_dir}/${PN}
		fperms -R =rX,ug+w /var/${c_dir}/${PN}
	done

	#Create all default dirs
	keepdir ${DHOMEDIR}
	dosym /var/log/${PN} ${DHOMEDIR}/logs
	dosym /var/cache/${PN} ${DHOMEDIR}/cache
	keepdir ${DHOMEDIR}/db_backup

	fowners -R sabnzbd:sabnzbd ${DHOMEDIR}
	fperms -R =rX,ug+w ${DHOMEDIR}

	#Add themes & code
	dodir /usr/share/${PN}
	insinto /usr/share/${PN}
	for couch_dir in ${PN} init libs ; do
		doins -r ${couch_dir} || die "failed to install ${couch_dir}"
	done
	doins CouchPotato.py || die "installing CouchPotato.py"

	#fix permissions
	fowners -R sabnzbd:sabnzbd /usr/share/${PN}
	fperms -R =rX,ug+w /usr/share/${PN}
}

pkg_postinst() {

	# optimizing
	python_mod_optimize "/usr/share/${PN}"

	einfo "Default directory: ${HOMEDIR}"
	einfo ""
	einfo "Run: gpasswd -a <user> sabnzbd"
	einfo "to add an user to the sabnzbd group so it can edit sabnzbd files"
	einfo ""
	ewarn "Please configure /etc/conf.d/${PN} before starting!"
	einfo ""
	einfo "Start with ${ROOT}etc/init.d/${PN} start"
	einfo ""
	ewarn "When upgrading ${PN}, don't forget to fix the permissions"
	ewarn "on the config file after merging the changes."
	ewarn ""
	ewarn "chown -cvR sabnzbd:sabnzbd /etc/sabnzbd && chmod -cvR 660 /etc/sabnzbd"
}
