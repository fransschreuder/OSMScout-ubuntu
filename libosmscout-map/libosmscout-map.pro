TARGET = libosmscout-map
TEMPLATE = lib
CONFIG += staticlib  c++11
INCLUDEPATH += include ../libosmscout/include

macx {
    QMAKE_CXXFLAGS = -mmacosx-version-min=10.7 -std=gnu0x -stdlib=libc+
    CONFIG +=c++11
}

SOURCES = \
          ../libosmscout-map/src/osmscout/MapPainter.cpp \
          ../libosmscout-map/src/osmscout/MapParameter.cpp \
          ../libosmscout-map/src/osmscout/MapService.cpp \
          ../libosmscout-map/src/osmscout/StyleConfig.cpp \
          ../libosmscout-map/src/osmscout/oss/Parser.cpp \
          ../libosmscout-map/src/osmscout/oss/Scanner.cpp
    

HEADERS = \
        ../libosmscout-map/include/osmscout/MapFeatures.h \
        ../libosmscout-map/include/osmscout/MapPainter.h \
        ../libosmscout-map/include/osmscout/MapParameter.h \
        ../libosmscout-map/include/osmscout/MapService.h \
        ../libosmscout-map/include/osmscout/StyleConfig.h \
        ../libosmscout-map/include/osmscout/oss/Parser.h \
        ../libosmscout-map/include/osmscout/oss/Scanner.h \
        ../libosmscout-map/include/osmscout/private/Config.h \
        ../libosmscout-map/include/osmscout/private/MapImportExport.h

#unix {
#    target.path = /usr/lib
#    INSTALLS += target
#}



