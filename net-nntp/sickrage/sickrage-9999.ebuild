# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI="3"
PYTHON_DEPEND="2:2.7"
inherit eutils multilib python git-2

DESCRIPTION="Video File Manager for TV Shows, It watches for new episodes of your favorite shows and when they are posted it does its magic."
HOMEPAGE="http://www.sickrage.tv/"
SRC_URI=""

EGIT_REPO_URI="git://github.com/SiCKRAGETV/SickRage.git"

HOMEDIR="${ROOT}var/lib/${PN}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="rss ssl logrotate -cherrypy"

RDEPEND="
		>=dev-lang/python-2.7
		dev-python/cheetah
		rss? ( dev-python/feedparser )
		ssl? ( dev-python/pyopenssl )"
DEPEND="${RDEPEND}
		net-nntp/sabnzbd"

DOCS=( "COPYING.txt" "readme.md" )

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

	for i in log cache ; do
		keepdir /var/${i}/${PN}
	    fowners -R sabnzbd:sabnzbd /var/${i}/${PN}
		fperms -R =rX,ug+w /var/${i}/${PN}
	done

	#Create all default dirs
	keepdir ${HOMEDIR}

	fowners -R sabnzbd:sabnzbd ${HOMEDIR}
	fperms -R =rX,ug+w ${HOMEDIR}

	#Add themes & code
	dodir /usr/share/${PN}
	insinto /usr/share/${PN}
	for sick_dir in ${PN} data lib cherrypy autoProcessTV tests ; do
		doins -r ${sick_dir} || die "failed to install ${sick_dir}"
	done
	doins SickBeard.py || die "installing SickBeard.py"

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
