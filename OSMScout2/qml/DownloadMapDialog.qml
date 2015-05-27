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

            text: "This applications requires a preprocessed map,<br/> please download or generate a map<br/> and put the files in <br/>&lt;SD_CARD&gt;/Pictures/osmscout/<br/><br/>"+
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
    }
}
