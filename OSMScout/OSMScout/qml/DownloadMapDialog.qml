import QtQuick 2.2
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.1

import net.sf.libosmscout.map 1.0

import "custom"

MapDialog {
    id: dialog

    label: "Download Maps..."

    content : ColumnLayout {
        id: mainFrame


        Text {
            Layout.fillWidth: true

            text: "<b>Download Maps</b>"
            font.pixelSize: Theme.textFontSize*1.2
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            Layout.fillWidth: true

            text: "This applications requires a preprocessed map,<br/> please download or generate a map<br/> and put the files in <br/>&lt;SD_CARD&gt;/Maps/osmscout/<br/><br/>"+
                  "For instructions please see <br/>http://wiki.openstreetmap.org/wiki/<br/>Libosmscout#Converting_OSM_Data";
            font.pixelSize: Theme.textFontSize
            horizontalAlignment: Text.AlignHCenter
        }

        RowLayout {
            id: buttonRow
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            spacing: 10

            Item {
                Layout.fillWidth: true
            }

            Button {
                id: ok
                text: "OK"

                onClicked: {
                    close()
                }
            }
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true

            border.color: "lightgrey"
            border.width: 1

            MapListModel{
                id: mapsModel
            }

            ListView {
                id: mapsView

                model: mapsModel

                anchors.fill: parent

                clip: true

                delegate: Item {
                    id: item

                    anchors.right: parent.right;
                    anchors.left: parent.left;
                    height: text.implicitHeight+5

                    Text {
                        id: text

                        y:2
                        x: 2
                        width: parent.width-4
                        text: name
                        font.pixelSize: Theme.textFontSize
                    }

                    Rectangle {
                        x: 2
                        y: parent.height-2
                        width: parent.width-4
                        height: 1
                        color: "lightgrey"
                    }
                }
            }

            ScrollIndicator {
                flickableArea: mapsView
            }
        }

    }
}
