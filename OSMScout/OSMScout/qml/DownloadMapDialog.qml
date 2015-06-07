import QtQuick 2.2
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.1
import Qt.labs.settings 1.0

import net.sf.libosmscout.map 1.0

import "custom"

MapDialog {
    id: dialog

    label: "Download Maps..."
    Settings{
        id: settings
        property int selectedmap: 0
    }

    MapListModel{
        id: mapsModel
    }

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
            width: parent.width
            id: tAvMaps
            text: "<b>Available maps:</b>"
        }



        ListView {
            id: mapsView

            model: mapsModel
            width: parent.width
            //anchors.fill: parent
            height: units.gu(30) //parent.height-tAvMaps.height-ok.height-text1.height-text2.height
            //clip: true
            delegate:ListItemWithActions
            {
                leftSideAction: Action {
                    iconName: "delete"
                    text: i18n.tr("Delete")
                    onTriggered: {
                        console.log("Delete" + index);
                    }
                }
                onItemClicked: {
                    settings.selectedmap = index;
                }
                width: parent.width; height: col.height
                color: settings.selectedmap==index?UbuntuColors.green:UbuntuColors.lightGrey
                contents: Column {
                    id: col
                    spacing: units.gu(0.5)
                    Label {
                        text: model.name
                        fontSize: "medium"
                        font.bold: settings.selectedmap==index
                    }
                    Label
                    {
                        text: model.path
                        fontSize: "small"
                    }

                }
            }

        }
        Button {
            id: ok
            text: "OK"
            width: parent.width
            onClicked: {
                map.reopenMap();
                close();
            }
        }
    }
}
