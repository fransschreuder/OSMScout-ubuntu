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
            height: units.gu(15) //parent.height-tAvMaps.height-ok.height-text1.height-text2.height
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
        DownloadManager{
            property string downloadUrl: "http://schreuderelectronics.com/osm/benelux/";
            property string downloadFolder: "/media/phablet/AFE0-2E94/Maps/benelux";
            id: downloadmanager
            onProgress: {
                progressbar.value = nPercentage;

            }
            onDownloadComplete:
            {
                if(mainFrame.currentFileIndex < 20)
                {
                    downloadmanager.download(downloadUrl+mainFrame.getNextFilename(), downloadFolder);
                }
                else
                {
                    download.enabled = true;
                }
            }
        }
        property int currentFileIndex: -1;
        function getNextFilename(){
            var filenames = [
                "areaarea.idx",
                "bounding.dat",
                "routebicycle.dat",
                "routefoot.idx",
                "waysopt.dat",
                "areanode.idx",
                "intersections.dat",
                "routebicycle.idx",
                "standard.oss",
                "areas.dat",
                "intersections.idx",
                "routecar.dat",
                "types.dat",
                "areasopt.dat",
                "location.idx",
                "routecar.idx",
                "water.idx",
                "areaway.idx",
                "nodes.dat",
                "routefoot.dat",
                "ways.dat"];
            if(mainFrame.currentFileIndex<20&&mainFrame.currentFileIndex>=-1)
            {
                mainFrame.currentFileIndex++;
                return filenames[mainFrame.currentFileIndex];
            }
            else
            {
                mainFrame.currentFileIndex = -1;
                return "";
            }

        }

        Button {
            id: download
            text: "Download Benelux"
            width: parent.width
            onClicked:
            {
                downloadmanager.downloadFolder = mapsModel.getPreferredDownloadDir()+"/benelux";
                console.log("Download location: "+mapsModel.getPreferredDownloadDir()+"/benelux");
                download.enabled = false;
                mainFrame.currentFileIndex = -1;
                downloadmanager.download(downloadmanager.downloadUrl+mainFrame.getNextFilename(), downloadmanager.downloadFolder);
            }
        }
        Button {
            id: pause
            text: "Pause Download"
            width: parent.width
            onClicked:{
                if(text==="Pause Download")
                {
                    downloadmanager.pause();
                    text = "Resume Download";
                }
                else
                {
                    downloadmanager.resume();
                    text = "Pause Download";
                }
            }
        }
        Label{
            width: parent.width
            text: "Current file:"
        }

        ProgressBar{
            id: progressbar
            width: parent.width
            minimumValue: 0
            maximumValue: 100
            value: 0
        }
        Label{
            width: parent.width
            text: "Overall progress:"
        }
        ProgressBar{
            id: progressbarFiles
            width: parent.width
            minimumValue: 0
            maximumValue: 20
            value: mainFrame.currentFileIndex>=0?mainFrame.currentFileIndex:0
        }
    }
}
