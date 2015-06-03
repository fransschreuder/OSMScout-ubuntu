import QtQuick 2.2
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.1

import net.sf.libosmscout.map 1.0

import "custom"

MapDialog {
    id: dialog

    label: "Download Maps..."


    content : Column {
        id: mainFrame

        width: parent.width
        height: parent.height
        Text {
            id: text1
            //Layout.fillWidth: true
            width: parent.width
            text: "<b>Download Maps</b>"
            //font.pixelSize: Theme.textFontSize*1.2
            //horizontalAlignment: Text.AlignHCenter
        }

        Text {
            id: text2
            //Layout.fillWidth: true
            width: parent.width
            text: "This applications requires a preprocessed map,<br/> please download or generate a map<br/> and put the files in <br/>&lt;SD_CARD&gt;/Maps/osmscout/<br/><br/>"+
                  "For instructions please see <br/>http://wiki.openstreetmap.org/wiki/<br/>Libosmscout#Converting_OSM_Data<br/>";
            //font.pixelSize: Theme.textFontSize
            //horizontalAlignment: Text.AlignHCenter
        }


        Text{
            id: tAvMaps
            text: "<b>Available maps:</b>"
        }


        MapListModel{
            id: mapsModel
        }

        ListView {
            id: mapsView

            model: mapsModel
            width: parent.width
            //anchors.fill: parent
            height: units.gu(30) //parent.height-tAvMaps.height-ok.height-text1.height-text2.height
            clip: true

            delegate: Item {
                id: item
                width: parent.width;
                anchors.right: parent.right;
                anchors.left: parent.left;
                height: text.implicitHeight+5

                Text {
                    id: text

                    y:2
                    x: 2
                    width: parent.width-4
                    text: path
                    font.pixelSize: Theme.textFontSize
                }
            }
        }
        Button {
            id: ok
            text: "OK"
            width: parent.width
            onClicked: {
                close()
            }
        }
    }
}
