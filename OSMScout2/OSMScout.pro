TEMPLATE = app
load(ubuntu-click)

# specify the manifest file, this file is required for click
# packaging and for the IDE to create runconfigurations
UBUNTU_MANIFEST_FILE=manifest.json.in
#QT_CONFIG -= no-pkg-config
CONFIG += release
CONFIG += qt thread c++11

QT += core gui widgets qml quick svg positioning

#PKGCONFIG += libosmscout-map-qt

gcc:QMAKE_CXXFLAGS += -fopenmp

#QMAKE_CFLAGS = -O3 -march=armv7-a -mtune=cortex-a8
#QMAKE_CXXFLAGS = -O3 -march=armv7-a -mtune=cortex-a8

INCLUDEPATH = src
INCLUDEPATH += ../libosmscout/include/
INCLUDEPATH += ../libosmscout-map/include
INCLUDEPATH += ../libosmscout-map-qt/include

release: DESTDIR = release
debug:   DESTDIR = debug

OBJECTS_DIR = $$DESTDIR/
MOC_DIR = $$DESTDIR/
RCC_DIR = $$DESTDIR/
UI_DIR = $$DESTDIR/

SOURCES = src/OSMScout.cpp \
          src/Settings.cpp \
          src/Theme.cpp \
          src/DBThread.cpp \
          src/MapWidget.cpp \
          src/MainWindow.cpp \
          src/SearchLocationModel.cpp \
          src/RoutingModel.cpp \
          ../libosmscout-map-qt/src/osmscout/MapPainterQt.cpp

HEADERS = src/Settings.h \
          src/Theme.h \
          src/DBThread.h \
          src/MapWidget.h \
          src/MainWindow.h \
          src/SearchLocationModel.h \
          src/RoutingModel.h \
          ../libosmscout-map-qt/include/osmscout/MapPainterQt.h  
          ../libosmscout-map-qt/include/osmscout/MapQtFeatures.h
          ../libosmscout-map-qt/include/osmscout/private/MapQtImportExport.h
          

QMLFILES += \
    qml/custom/MapButton.qml \
    qml/main.qml \
    qml/RoutingDialog.qml \
    qml/AboutDialog.qml \
    qml/SearchDialog.qml

CUSTOMQMLFILES += \
    qml/custom/LineEdit.qml \
    qml/custom/DialogActionButton.qml \
    qml/custom/LocationEdit.qml \
    qml/custom/LocationSearch.qml \
    qml/custom/ScrollIndicator.qml \
    qml/custom/MapDialog.qml

PICFILES += \
    pics/DeleteText.svg

MAPFILES += \
    netherlands-osm-converted/bounding.dat \
    netherlands-osm-converted/wayaddress.dat \
    netherlands-osm-converted/distribution.dat \
    netherlands-osm-converted/types.dat \
    netherlands-osm-converted/map.ost \
    netherlands-osm-converted/turnrestr.dat \
    netherlands-osm-converted/standard.oss \
    netherlands-osm-converted/wayareablack.dat \
    netherlands-osm-converted/nodeaddress.dat \
    netherlands-osm-converted/areasopt.dat \
    netherlands-osm-converted/waysopt.dat \
    netherlands-osm-converted/routecar.idx \
    netherlands-osm-converted/routebicycle.idx \
    netherlands-osm-converted/routefoot.idx \
    netherlands-osm-converted/intersections.idx \
    netherlands-osm-converted/areaaddress.dat \
    netherlands-osm-converted/areaway.idx \
    netherlands-osm-converted/water.idx \
    netherlands-osm-converted/location.idx \
    netherlands-osm-converted/intersections.dat \
    netherlands-osm-converted/ways.idmap \
    netherlands-osm-converted/areaarea.idx \
    netherlands-osm-converted/location.txt \
    netherlands-osm-converted/areanode.idx \
    netherlands-osm-converted/routecar.dat \
    netherlands-osm-converted/ways.dat \
    netherlands-osm-converted/routebicycle.dat \
    netherlands-osm-converted/routefoot.dat

qml_files.path = /qml
qml_files.files = $${QMLFILES}
INSTALLS+=qml_files

custom_qml_files.path = /qml/custom
custom_qml_files.files = $${CUSTOMQMLFILES}
INSTALLS+=custom_qml_files

pic_files.path = /pics
pic_files.files = $${PICFILES}
INSTALLS+=pic_files


map_files.path = /
#$${UBUNTU_CLICK_BINARY_PATH}
map_files.files = $${MAPFILES}

INSTALLS+=map_files

RESOURCES += \
    res.qrc



OTHER_FILES += OSMScout.apparmor \
               OSMScout.desktop \
               OSMScout.png


#specify where the config files are installed to
config_files.path = /OSMScout
config_files.files += $${OTHER_FILES}
message($$config_files.files)
INSTALLS+=config_files



LIBS += ../libosmscout/src/.libs/libosmscout.so \
                     ../libosmscout-map/src/.libs//libosmscoutmap.so \
                     ../libosmscout/src/.libs/libosmscout.so.0 \
                     ../libosmscout-map/src/.libs//libosmscoutmap.so.0
#                     ../libosmscout-map-qt/src/.libs/libosmscoutmapqt.so

#ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
target.path = $${UBUNTU_CLICK_BINARY_PATH}

INSTALLS+=target

libfiles.files = $${LIBS}
libfiles.path = $${UBUNTU_CLICK_BINARY_PATH}/..

INSTALLS+=libfiles
