## Process this file with automake to produce Makefile.in
## Created by Anjuta

SUBDIRS = src po

dist_doc_DATA = \
	README \
	COPYING \
	AUTHORS \
	ChangeLog \
	INSTALL \
	NEWS


INTLTOOL_FILES = intltool-extract.in \
	intltool-merge.in \
	intltool-update.in

Applicationsdir = ${prefix}/share/applications
Applications_DATA = OSMScoutImport.desktop

osmscoutimporticondir = ${prefix}/share/pixmaps
osmscoutimporticon_DATA = OSMScout.png

EXTRA_DIST = \
	$(INTLTOOL_FILES) $(Applications_DATA) $(osmscoutimporticon_DATA)

DISTCLEANFILES = intltool-extract \
	intltool-merge \
	intltool-update \
	po/.intltool-merge-cache


# Remove doc directory on uninstall
uninstall-local:
	-rm -r $(docdir)
