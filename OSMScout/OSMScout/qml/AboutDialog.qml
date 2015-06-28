import QtQuick 2.2
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0
import net.sf.libosmscout.map 1.0

import "custom"

Component {
    id: dialog
    Dialog {
        signal closed();
        id: dialogue
        title: qsTr("About OSMScout")

        Label {
            width: parent.width
            wrapMode: Text.Wrap
            text: qsTr("Ubuntu Touch version of OSMScout")+"<br/>"+qsTr("See")+" <br/><a href=https://github.com/fransschreuder/libosmscout>https://github.com/fransschreuder/libosmscout</a><br/>"+qsTr("Ubuntu modifications by")+" Schreuder Electronics"
        }

        Label {
            width: parent.width
            wrapMode: Text.Wrap
            text: qsTr("All geographic data:")+"<br/>© "+qsTr("OpenStreetMap contributors<br/>See www.openstreetmap.org/copyright")
        }


        Button {
            width: parent.width
            id: ok
            text: qsTr("OK")

            onClicked: {
                PopupUtils.close(dialogue);
                closed();
            }
        }
    }
}
