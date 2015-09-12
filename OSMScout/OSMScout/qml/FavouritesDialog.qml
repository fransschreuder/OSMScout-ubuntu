import QtQuick 2.2
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0
import net.sf.libosmscout.map 1.0
import Qt.labs.settings 1.0

import "custom"

Component {
    id: dialog
    Dialog {
        signal closed();
        signal opened();
        id: dialogue
        title: qsTr("Favourites")

        Settings{
            id: favSettings
            category: "favourites"
            property string favs: "";
            property string home: "";

        }

        function saveFavourites(){
            var i;
            favSettings.favs="";
            for(i=0; i<favModel.count; i++)
            {
                favSettings.favs=favSettings.favs+favModel.get(i).title+";"
            }
        }

        function loadFavourites(){
            var favs=favSettings.favs.split(";");
            favModel.clear();
            console.log("Loading favourites...");
            for(var i=0; i<favs.length; i++)
            {
                if(favs[i]!=="")
                {
                    console.log("Appending: "+favs[i]);
                    favModel.append({'title':favs[i]});
                }
            }
        }

        onOpened: loadFavourites();






        ListModel {
            id: favModel
        }

        LocationEdit {
            text: qsTr("<current position>");
            width: targetInput.width
            height: units.gu(4)
            id: locationInput
            //anchors.right: targetInput.right
            horizontalAlignment: TextInput.AlignLeft
        }

        Button {
            id: addFav;
            text: qsTr("Add to Favourites");
            onClicked:{
                var item = {'title': locationInput.text};
                favModel.append(item);

                saveFavourites();
            }
        }



        ListView{
            width: parent.width
            id: favSelector;
            model: favModel;
            height: units.gu(16);
            delegate: ListItemWithActions{
                height: units.gu(4)
                width: parent.width
                //triggerActionOnMouseRelease: true

                leftSideAction: Action {
                    iconName: "delete"
                    text: i18n.tr("Delete")
                    onTriggered: {
                        favModel.remove(index);
                        dialogue.saveFavourites();
                    }
                }

                /*rightSideActions: [
                    Action {
                        iconName: "alarm-clock"
                        text: i18n.tr("Alarm")
                    },

                    Action {
                        iconName: "add"
                        text: i18n.tr("Add")
                    }
                ]*/

                contents: Label {
                    text: title
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }



        Button {
            id: saveHome;
            text: qsTr("Save as home");
            onClicked: {
                favSettings.home = locationInput.text;
            }
        }

        Row{
            width: parent.width
            Icon{
                id: homeIcon
                name: "home"
                width: units.gu(4);
            }
            Label{
                anchors.verticalCenter: homeIcon.verticalCenter
                text: favSettings.home;
            }
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
