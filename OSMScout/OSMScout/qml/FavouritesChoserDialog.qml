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

        function getValue(){
            return favModel.get(favSelector.selectedIndex).title;
        }

        onOpened: loadFavourites();


        OptionSelector {
            width: parent.width
            id: favSelector
            model: favModel
            expanded: false
            colourImage: true
            delegate: selectorDelegate
        }
        Component {
            id: selectorDelegate
            OptionSelectorDelegate { text: title }
        }



        ListModel {
            id: favModel
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
