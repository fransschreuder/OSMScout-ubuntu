#!/bin/bash

DISTS="trusty utopic vivid"

if [ $# -ne 0 ]
then
  RELEASE=$1
  if [ $# -ne 1 ]
  then
    DISTS=$2
  fi
else
  RELEASE=$(date +"%y%m%d")
  RELEASE=${RELEASE:0:6}
#-$(date +%Y%m%d)
fi

echo Building release: $RELEASE


if [ -d release ]
then
	echo Directory release exists, removing ...
	rm -rf release
fi
echo making release directory
mkdir release
#mkdir release/usbpicprog
#mkdir release/firmware

echo exporting git tree...
#svn export uc_code release/firmware/firmware-$RELEASE
#svn export boot release/firmware/boot1.0
git clone ./ release/
mv release/OSMScout/libosmscout release/libosmscout-$RELEASE
mv release/OSMScout/libosmscout-import release/libosmscout-import-$RELEASE
mv release/OSMScout/Import release/osmscoutimport-$RELEASE
rm release/LICENSE
rm release/README
rm release/build-src-package.sh
rm -rf release/OSMScout/

echo creating autogen files
cd release/libosmscout-$RELEASE
sed -i 's/SUBDIRS = src include tests/SUBDIRS = src include/g' Makefile.am
./autogen.sh
make distclean
rm -rf autom4te.cache

cd ..
echo creating source archive...
tar -zcvhf libosmscout_$RELEASE.orig.tar.gz libosmscout-$RELEASE
rm -rf libosmscout-$RELEASE
tar -zxvf libosmscout_$RELEASE.orig.tar.gz
cd libosmscout-$RELEASE

COUNT=0

for DIST in ${DISTS} ; do
	COUNT=$(($COUNT-1))
	dch -D $DIST -m -v $RELEASE$COUNT -b
	debuild -S -k8AD5905E
done
cd ..
##################
echo creating autogen files
cd libosmscout-import-$RELEASE
./autogen.sh
./configure
make distclean
rm -rf autom4te.cache

cd ..
echo creating source archive...
tar -zcvhf libosmscout-import_$RELEASE.orig.tar.gz libosmscout-import-$RELEASE
rm -rf libosmscout-import-$RELEASE
tar -zxvf libosmscout-import_$RELEASE.orig.tar.gz
cd libosmscout-import-$RELEASE

COUNT=0
for DIST in ${DISTS} ; do
	COUNT=$(($COUNT-1))
	dch -D $DIST -m -v $RELEASE$COUNT -b
	debuild -S -k8AD5905E
done

cd ..
####################
echo creating autogen files
cd osmscoutimport-$RELEASE
./autogen.sh
make distclean
rm -rf autom4te.cache

cd ..
echo creating source archive...
tar -zcvhf osmscoutimport_$RELEASE.orig.tar.gz osmscoutimport-$RELEASE
rm -rf osmscoutimport-$RELEASE
tar -zxvf osmscoutimport_$RELEASE.orig.tar.gz
cd osmscoutimport-$RELEASE

COUNT=0
for DIST in ${DISTS} ; do
	COUNT=$(($COUNT-1))
	dch -D $DIST -m -v $RELEASE$COUNT -b
	debuild -S -k8AD5905E
done
cd ..
