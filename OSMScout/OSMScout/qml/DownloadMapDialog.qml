import QtQuick 2.2
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0 as Popups
import Qt.labs.settings 1.0

import net.sf.libosmscout.map 1.0

import "custom"

MapDialog {
    id: dialog
    fullscreen: true

    label: qsTr("Download Maps...")
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

    Component{
        id: confirmComponent
        Popups.Dialog {


            id: confirmDialog
            title: qsTr("Are you sure?")
            text: qsTr("Delete")+" "+mapsModel.get(mapsModel.deleteIndex)+"?"
            Button {
                text: qsTr("OK")
                onClicked: {

                    dialog.visible = true;
                    console.log("Delete " + mapsModel.deleteIndex);
                    if(mapsModel.deleteItem(mapsModel.deleteIndex))
                    {
                        if(settings.selectedmap > mapsModel.deleteIndex)
                        {
                            settings.selectedmap--;
                        }
                    }

                    PopupUtils.close(confirmDialog);
                }

            }

            Button {
                text: qsTr("Cancel")
                onClicked: {
                    dialog.visible = true;
                    PopupUtils.close(confirmDialog);
                }
            }
        }
    }

    function openConfirmDialog(index){
        mapsModel.deleteIndex = index;
        dialog.visible = false;
        PopupUtils.open(confirmComponent);
    }
    property string errorMessage: ""
    Component{
        id: errorComponent

        Popups.Dialog {
            id: errorDialog
            title: qsTr("Error")
            text: dialog.errorMessage;
            Item{
                id: iconContainer
                height: icon.height
                Icon{
                    id: icon
                    anchors.centerIn: parent
                    name: "error"
                    width: units.gu(6);
                    height: width
                }
            }

            Button {
                text: qsTr("OK")
                onClicked: {

                    dialog.visible = true;
                    PopupUtils.close(errorDialog);
                }

            }


        }
    }

    function showError(message){
        dialog.errorMessage = message;
        dialog.visible = false;
        PopupUtils.open(errorComponent);
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
        if(dialog.currentFileIndex<21&&dialog.currentFileIndex>=-1)
        {
            dialog.currentFileIndex++;
            dialog.currentFile = filenames[dialog.currentFileIndex];
            return filenames[dialog.currentFileIndex];
        }
        else
        {
            dialog.currentFileIndex = -1;
            return "";
        }

    }

    content: Flickable
    {
        width: map.width - 2*  Theme.horizSpace
        height: map.height - 5*Theme.vertSpace - tAvMaps.height
        contentHeight: mainFrame.height
        contentWidth: parent.width - 2* Theme.horizSpace
        flickableDirection: Flickable.VerticalFlick
        Column
        {

            spacing: Theme.vertSpace
            id: mainFrame
            width: parent.width
            //width: parent.contentWidth
            //height: tavMaps.height + mapsView.height +

            Label{
                width: parent.width
                id: tAvMaps
                text: "<b>"+qsTr("Installed maps:")+"</b>"
            }



            ListView {
                id: mapsView

                model: mapsModel
                width: parent.width
                //anchors.fill: parent
                interactive: false
                height: contentHeight;//<units.gu(25)?contentHeight:units.gu(25)//delegate.height*3//units.gu(30)
                //clip: true
                delegate:ListItemWithActions
                {
                    id: mapsItem
                    leftSideAction: Action {
                        iconName: "delete"
                        text: qsTr("Delete")
                        onTriggered: {
                            dialog.openConfirmDialog(index);
                        }
                    }
                    onItemClicked: {
                        settings.selectedmap = index;
                    }
                    width: parent.width; height: col.height
                    //color: settings.selectedmap==index?UbuntuColors.green:UbuntuColors.lightGrey
                    contents: Row{
                        id: row
                        height: col.height
                        width: parent.width
                        spacing: units.gu(0.5)
                        Column {
                            id: col
                            spacing: units.gu(0.5)
                            width: parent.width  -units.gu(5.5)
                            //height: itemL1.height+itemL2.height+units.gu(0.5)
                            Label {
                                //width: parent.width - checkIcon.width -units.gu(0.5)
                                id: itemL1
                                text: model.name
                                fontSize: "medium"
                                font.bold: settings.selectedmap==index
                            }
                            Label
                            {
                                //width: parent.width - checkIcon.width -units.gu(0.5)
                                id: itemL2
                                text: model.path
                                fontSize: "small"
                            }

                        }
                        Icon{
                            id: checkIcon
                            name: settings.selectedmap==index?"select":""
                            width: units.gu(4.5)
                            height: width
                        }
                    }


                }

            }
            Button {
                id: download1
                text: qsTr("Download")
                visible: false
                width: parent.width
                onClicked:
                {
                    progressItem1.visible = true;
                    progressItem2.visible = true;
                    var name = downloadsListModel.get(downloadsView.downloadMapIndex);
                    downloadmanager.downloadFolder = mapsModel.getPreferredDownloadDir()+"/"+name;
                    console.log("Download location: "+mapsModel.getPreferredDownloadDir()+"/"+name);
                    download1.enabled = false;
                    download2.enabled = false;
                    dialog.currentFileIndex = -1;
                    pause1.visible = true;
                    pause2.visible = true;
                    downloadmanager.download(downloadmanager.downloadUrl+name+"/"+dialog.getNextFilename(), downloadmanager.downloadFolder);
                }
            }
            Button {
                id: pause1
                text: qsTr("Pause Download")
                width: parent.width
                visible: false
                onClicked:{
                    if(text===qsTr("Pause Download"))
                    {
                        downloadmanager.pause();
                        text = qsTr("Resume Download");
                        pause2.text = text;
                    }
                    else
                    {
                        downloadmanager.resume();
                        text = qsTr("Pause Download");
                        pause2.text = text;
                    }
                }
            }

            Item{
                id: progressItem1
                visible: false;
                width: parent.width;
                height: progressbar1.height+l1_1.height+l2_1.height+progressbarFiles1.height
                Column{
                    //height: parent.height
                    width: parent.width
                    Label{
                        id: l1_1
                        width: parent.width
                        text: qsTr("Current file:")
                    }
                    ProgressBar{
                        id: progressbar1
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
                        id: progressbarFiles1
                        width: parent.width
                        minimumValue: 0
                        maximumValue: 22
                        value: dialog.currentFileIndex>=0?dialog.currentFileIndex:0
                    }
                }


            }
            Button {
                id: ok1
                text: qsTr("Close")
                width: parent.width
                onClicked: {
                    map.reopenMap();
                    close();
                }
            }
            Label{
                text: "<b>"+qsTr("Select map to download:")+"</b>"
                width: parent.width
            }

            ListView {
                property int downloadMapIndex: -1
                id: downloadsView

                model: downloadsListModel
                width: parent.width
                //anchors.fill: parent
                interactive: false
                height: contentHeight;//<units.gu(25)?contentHeight:units.gu(25)
                //clip: true
                delegate:ListItemWithActions
                {
                    id: downloadsItem

                    onItemClicked: {
                        downloadsView.downloadMapIndex = index;
                        download1.text = "Download " + model.name;
                        download1.visible = true;
                        download2.text = "Download " + model.name;
                        download2.visible = true;
                    }
                    width: parent.width; height: downloadscol.height
                    //color: settings.selectedmap==index?UbuntuColors.green:UbuntuColors.lightGrey
                    contents: Row{
                        id: downloadsrow
                        height: downloadscol.height
                        width: parent.width
                        spacing: units.gu(0.5)
                        Column {
                            id: downloadscol
                            spacing: units.gu(0.5)
                            width: parent.width  -units.gu(5.5)
                            //height: itemL1.height+itemL2.height+units.gu(0.5)
                            Label {
                                //width: parent.width - checkIcon.width -units.gu(0.5)
                                //id: itemL1
                                text: model.name
                                fontSize: "medium"
                                font.bold: downloadsView.downloadMapIndex==index
                            }
                            Label
                            {
                                //width: parent.width - checkIcon.width -units.gu(0.5)
                                //id: itemL2
                                text: model.size
                                fontSize: "small"
                            }

                        }
                        Icon{
                            //id: checkIcon
                            name: downloadsView.downloadMapIndex==index?"select":""
                            width: units.gu(4.5)
                            height: width
                        }
                    }


                }

            }


            DownloadManager{
                property string downloadUrl: "http://schreuderelectronics.com/osm/";
                property string downloadFolder: "";
                id: downloadmanager
                onProgress: {
                    progressbar1.value = nPercentage;
                    progressbar2.value = nPercentage;

                }
                onDownloadComplete:
                {
                    if(downloadmanager.checkmd5sum(downloadFolder,dialog.currentFile))
                        console.log("md5sum correct");
                    else
                    {
                        console.log("md5sum failed");
                        dialog.showError(qsTr("md5sum of")+" "+dialog.currentFile+" "+qsTr("failed"));
                        download1.enabled = true;
                        progressItem1.visible = false;
                        pause1.visible = false;
                        download2.enabled = true;
                        progressItem2.visible = false;
                        pause2.visible = false;
                        mapsModel.refreshItems();
                        return;
                    }
                    if(dialog.currentFileIndex < 21)
                    {
                        var name = downloadsListModel.get(downloadsView.downloadMapIndex);
                        downloadmanager.download(downloadUrl+name+"/"+dialog.getNextFilename(), downloadFolder);
                    }
                    else
                    {
                        download1.enabled = true;
                        progressItem1.visible = false;
                        pause1.visible = false;
                        download2.enabled = true;
                        progressItem2.visible = false;
                        pause2.visible = false;
                        mapsModel.refreshItems();
                    }
                }
            }


            Button {
                id: download2
                text: qsTr("Download")
                visible: false
                width: parent.width
                onClicked:
                {
                    progressItem1.visible = true;
                    progressItem2.visible = true;
                    var name = downloadsListModel.get(downloadsView.downloadMapIndex);
                    downloadmanager.downloadFolder = mapsModel.getPreferredDownloadDir()+"/"+name;
                    console.log("Download location: "+mapsModel.getPreferredDownloadDir()+"/"+name);
                    download1.enabled = false;
                    download2.enabled = false;
                    dialog.currentFileIndex = -1;
                    pause1.visible = true;
                    pause2.visible = true;
                    downloadmanager.download(downloadmanager.downloadUrl+name+"/"+dialog.getNextFilename(), downloadmanager.downloadFolder);
                }
            }
            Button {
                id: pause2
                text: qsTr("Pause Download")
                width: parent.width
                visible: false
                onClicked:{
                    if(text===qsTr("Pause Download"))
                    {
                        downloadmanager.pause();
                        text = qsTr("Resume Download");
                        pause1.text = text;
                    }
                    else
                    {
                        downloadmanager.resume();
                        text = qsTr("Pause Download");
                        pause1.text = text;
                    }
                }
            }

            Item{
                id: progressItem2
                visible: false;
                width: parent.width;
                height: progressbar2.height+l1_2.height+l2_2.height+progressbarFiles2.height
                Column{
                    //height: parent.height
                    width: parent.width
                    Label{
                        id: l1_2
                        width: parent.width
                        text: qsTr("Current file:")
                    }
                    ProgressBar{
                        id: progressbar2
                        width: parent.width
                        minimumValue: 0
                        maximumValue: 100
                        value: 0
                    }
                    Label{
                        id: l2_2
                        width: parent.width
                        text: qsTr("Overall progress:")
                    }
                    ProgressBar{
                        id: progressbarFiles2
                        width: parent.width
                        minimumValue: 0
                        maximumValue: 22
                        value: dialog.currentFileIndex>=0?dialog.currentFileIndex:0
                    }
                }


            }


            Button {
                id: ok2
                text: qsTr("Close")
                width: parent.width
                onClicked: {
                    map.reopenMap();
                    close();
                }
            }

        }
    }
}
