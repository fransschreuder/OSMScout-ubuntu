## Process this file with automake to produce Makefile.in

## Created by Anjuta

AM_CPPFLAGS = \
	$(WX_CXXFLAGS) \
	-DPACKAGE_LOCALE_DIR=\""$(localedir)"\" \
	-DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
	-DPACKAGE_DATA_DIR=\""$(pkgdatadir)"\"

AM_CFLAGS =\
	 -Wall \
	 -g \
	 $(WX_CPPFLAGS)

bin_PROGRAMS = OSMScoutImport

OSMScoutImport_SOURCES = \
	main.cpp \
	MapImportFrameBase.cpp \
	MapImportFrame.cpp \
	main.h \
	MapImportFrameBase.h \
	MapImportFrame.h

OSMScoutImport_LDFLAGS = 

OSMScoutImport_LDADD = \
	 \
	$(WX_LIBS)



