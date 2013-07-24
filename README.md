#Experimental Gentoo Linux Ebuilds

This Git repository contains experimental ebuilds for [Gentoo Linux](http://www.gentoo.org/). At this time it consists of the following ebuilds

- [sabnzbd](http://sabnzbd.org/) - Binary Newsgrabber
- [sickbeard](http://sickbeard.com/) - Automatic NZB downloader for tv shows
- [couchpotato](http://couchpota.to/) - (v2) Automatic NZB downloader for movies
- [headphones](http://headphones.codeshy.com/forum/) - Automatic NZB downloader for music
- [yenc](http://www.golug.it/yenc.html) - updated version of yenc
- [multithreaded par2cmdline](http://chuchusoft.com/par2_tbb/index.html) - multithreaded version of par2cmdline

##Install overlay

Install **layman**, with **git**. This can be skipped if already done.
`USE="git"  emerge layman`

Install the overlay, and sync.

```bash
layman -o https://raw.github.com/sleepnmojo/mojo-overlay/master/overlay.xml -a mojo
layman -S
```

##Install packages

All packages are masked.  To install packages, add the following to `/etc/portage/package.keywords`

```bash
net-nntp/sabnzbd ~amd64
net-nntp/couchpotato ~amd64
net-nntp/sickbeard ~amd64
net-nntp/headphones ~amd64
dev-python/yenc ~amd64
app-arch/par2cmdline ~amd64
www-apps/maraschino ~amd64
```

Then emerge the packages needed.
