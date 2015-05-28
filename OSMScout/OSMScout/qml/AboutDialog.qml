import QtQuick 2.2
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.1

import net.sf.libosmscout.map 1.0

import "custom"

MapDialog {
    id: dialog

    label: "About..."

    content : ColumnLayout {
        id: mainFrame


        Text {
            Layout.fillWidth: true

            text: "<b>OSMScout</b>"
            font.pixelSize: Theme.textFontSize*1.2
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            Layout.fillWidth: true

            text: "Ubuntu Touch version of OSMScout<br/>See <br/><a href=https://github.com/fransschreuder/libosmscout>https://github.com/fransschreuder/libosmscout</a><br/>Ubuntu modifications by Schreuder Electronics"
            font.pixelSize: Theme.textFontSize
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            Layout.fillWidth: true

            text: "All geographic data:<br/>© OpenStreetMap contributors<br/>See www.openstreetmap.org/copyright"
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
