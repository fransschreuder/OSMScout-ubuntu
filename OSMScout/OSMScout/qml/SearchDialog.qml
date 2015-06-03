import QtQuick 2.3
import QtQuick.Layouts 1.1

import net.sf.libosmscout.map 1.0
import Ubuntu.Components 1.1

import "custom"

FocusScope {
    id: searchDialog

    property Item desktop;
    property rect desktopFreeSpace;

    property alias location: searchEdit.location;

    signal showLocation(Location location)
    width: desktop.width - 2* Theme.horizSpace

    Item {
        id: searchRectangle;

        width: searchDialog.width;
        height: searchDialog.height;

        Row {
            id: searchContent
            width: parent.width
            height: parent.heights
            spacing: Theme.horizSpace

            LocationSearch {
                id: searchEdit;

                focus: true

                width: searchDialog.width-(units.gu(4)+Theme.horizSpace)
                height: units.gu(4)

                desktop: searchDialog.desktop
                desktopFreeSpace: searchDialog.desktopFreeSpace
                location: location

                onShowLocation: {
                    searchDialog.showLocation(location);
                    mainWindow.routeTo = searchEdit.text;
                }
            }

            DialogActionButton {
                id: searchButton

                width: units.gu(4)
                height: units.gu(4)
                contentColor: UbuntuColors.orange
                textColor: "white"
                iconName: "search"

                onClicked: {
                    searchEdit.enforceLocationValue();

                    if (searchEdit.location !== null) {
                        showLocation(searchEdit.location);
                    }
                }
            }
        }
    }
}
