import QtQuick 2.2
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.1
import Qt.labs.settings 1.0
import Ubuntu.Components.Popups 1.0

import net.sf.libosmscout.map 1.0

import "custom"

Component{



    id: dialog
    Dialog
    {
        id: dialogue
        signal closed();

        Label{
            text: qsTr("Download Maps...")
        }
        Settings{
            id: settings
            property int selectedmap: 0
        }

        MapListModel{
            id: mapsModel
            property int deleteIndex: 0;
        }

        DownloadListModel{
            id: downloadsListModel
        }

        /*Component{
            id: confirmComponent

        }*/

        function openConfirmDialog(index){
            mapsModel.deleteIndex = index;

            confirmDialog.visible = true;
        }

        function showError(message){
            errorDialog.text = message;
            errorDialog.visible = true;
        }

        property int currentFileIndex: -1;
        property string currentFile: "";
        function getNextFilename(){
            var filenames = [
                "md5sums",
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
            if(dialogue.currentFileIndex<21&&dialogue.currentFileIndex>=-1)
            {
                dialogue.currentFileIndex++;
                dialogue.currentFile = filenames[dialogue.currentFileIndex];
                return filenames[dialogue.currentFileIndex];
            }
            else
            {
                dialogue.currentFileIndex = -1;
                return "";
            }

        }

        Column
        {

            spacing: Theme.vertSpace
            id: mainFrame
            width: parent.width


            Label{
                width: parent.width
                id: tAvMaps
                text: "<b>"+qsTr("Installed maps:")+"</b>"
            }

            OptionSelector{
                selectedIndex: settings.selectedmap
                id: mapsView
                model: mapsModel
                width: parent.width
                delegate:Component{
                    id: mapsItem
                    OptionSelectorDelegate{
                        text: "<b>"+model.name+"</b>";
                        subText: model.path;
                    }
                }
                onDelegateClicked: {
                    settings.selectedmap = index;
                }
            }
            Button{
                id: deleteButton
                width: parent.width
                color: UbuntuColors.orange
                iconName: "delete"
                text: qsTr("Delete")+" "+mapsModel.get(mapsView.selectedIndex)
                onClicked: {
                   dialogue.openConfirmDialog(mapsView.selectedIndex);
                }
            }

            Column {
                visible: false
                id: confirmDialog
                width: parent.width
                spacing: units.gu(0.5)
                /*Rectangle{
                    anchors.fill: parent
                    color: UbuntuColors.lightGrey
                    radius: units.gu(1)
                }*/

                Label{
                    text: qsTr("Delete")+" "+mapsModel.get(mapsModel.deleteIndex)+"?"
                }
                Button {
                    width: parent.width
                    color: UbuntuColors.orange
                    text: qsTr("OK")
                    onClicked: {

                        console.log("Delete " + mapsModel.deleteIndex);
                        if(mapsModel.deleteItem(mapsModel.deleteIndex))
                        {
                            if(settings.selectedmap > mapsModel.deleteIndex)
                            {
                                settings.selectedmap--;
                            }
                        }
                        freeSpace.text = mapsModel.getFreeSpace();
                        confirmDialog.visible = false;
                        mapsModel.refreshItems();
                    }

                }

                Button {
                    width: parent.width
                    text: qsTr("Cancel")
                    onClicked: {

                        confirmDialog.visible = false;
                    }
                }
            }

            Label{
                id: freeSpace
                text: mapsModel.getFreeSpace()
            }

            Button {
                id: download
                text: qsTr("Download")
                visible: false
                width: parent.width
                onClicked:
                {
                    errorDialog.visible = false;
                    progressItem.visible = true;
                    var name = downloadsListModel.get(downloadsView.selectedIndex);
                    downloadmanager.downloadFolder = mapsModel.getPreferredDownloadDir()+"/"+name;
                    console.log("Download location: "+mapsModel.getPreferredDownloadDir()+"/"+name);
                    download.enabled = false;
                    dialogue.currentFileIndex = -1;
                    pause.visible = true;
                    downloadmanager.download(downloadmanager.downloadUrl+name+"/"+dialogue.getNextFilename(), downloadmanager.downloadFolder);
                }
            }
            Button {
                id: pause
                text: qsTr("Pause Download")
                width: parent.width
                visible: false
                onClicked:{
                    if(text===qsTr("Pause Download"))
                    {
                        downloadmanager.pause();
                        text = qsTr("Resume Download");
                    }
                    else
                    {
                        downloadmanager.resume();
                        text = qsTr("Pause Download");
                    }
                }
            }

            Item{
                id: progressItem
                visible: false;
                width: parent.width;
                height: progressBar.height+l1_1.height+l2_1.height+progressBarFiles.height
                Column{
                    //height: parent.height
                    width: parent.width
                    Label{
                        id: l1_1
                        width: parent.width
                        text: qsTr("Current file:")
                    }
                    ProgressBar{
                        id: progressBar
                        width: parent.width
                        minimumValue: 0
                        maximumValue: 100
                        value: 0
                    }
                    Label{
                        id: l2_1
                        width: parent.width
                        text: qsTr("Overall progress:")
                    }
                    ProgressBar{
                        id: progressBarFiles
                        width: parent.width
                        minimumValue: 0
                        maximumValue: 21
                        value: dialogue.currentFileIndex>=0?dialogue.currentFileIndex:0
                    }
                }


            }


            Label{
                color: UbuntuColors.red
                id: errorDialog
                visible: false
                width: parent.width
                text: ""
            }



            Label{
                text: "<b>"+qsTr("Select map to download:")+"</b>"
                width: parent.width
            }

            OptionSelector {
                id: downloadsView

                model: downloadsListModel
                //width: parent.width
                //anchors.fill: parent
                //interactive: false
                //height: contentHeight;//<units.gu(25)?contentHeight:units.gu(25)
                //clip: true
                onDelegateClicked:
                {
                    download.text = "Download " + downloadsListModel.get(index);
                    download.visible = true;
                }

                delegate:Component{
                    id: downloadsViewDelegate
                    OptionSelectorDelegate{
                        id: downloadsItem
                        text: "<b>"+model.name+"</b>";
                        subText: model.size
                    }
                }
            }

            Button {
                id: ok
                text: qsTr("Close")
                width: parent.width
                onClicked: {
                    map.reopenMap();
                    PopupUtils.close(dialogue);

                }
            }

            DownloadManager{
                property string downloadUrl: "http://schreuderelectronics.com/osm/";
                property string downloadFolder: "";
                id: downloadmanager
                onProgress: {
                    progressBar.value = nPercentage;

                }
                onDownloadComplete:
                {
                    freeSpace.text = mapsModel.getFreeSpace();
                    if(downloadmanager.checkmd5sum(downloadFolder,dialogue.currentFile))
                        console.log("md5sum correct");
                    else
                    {
                        console.log("md5sum failed");
                        dialogue.showError(qsTr("md5sum of")+" "+dialogue.currentFile+" "+qsTr("failed"));
                        download.enabled = true;
                        progressItem.visible = false;
                        pause.visible = false;
                        mapsModel.refreshItems();
                        return;
                    }
                    if(dialogue.currentFileIndex < 21)
                    {
                        var name = downloadsListModel.get(downloadsView.selectedIndex);
                        downloadmanager.download(downloadUrl+name+"/"+dialogue.getNextFilename(), downloadFolder);
                    }
                    else
                    {
                        download.enabled = true;
                        progressItem.visible = false;
                        pause.visible = false;
                        mapsModel.refreshItems();
                    }
                }
            }
        }
    }
}
