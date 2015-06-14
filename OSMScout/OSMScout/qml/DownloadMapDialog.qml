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

    DownloadListModel{
        id: downloadsListModel
    }

    content : Flickable
    {
        width: map.width - 2* Theme.vertSpace
        height: map.height - 2* Theme.horizSpace
        contentHeight: mainFrame.height
        contentWidth: parent.width - 2* Theme.horizSpace
        Column
        {
            spacing: Theme.vertSpace
            id: mainFrame

            width: parent.width
            //height: tavMaps.height + mapsView.height +

            Label{
                width: parent.width
                id: tAvMaps
                text: "<b>Installed maps:</b>"
            }



            ListView {
                id: mapsView

                model: mapsModel
                width: parent.width
                //anchors.fill: parent
                height: contentHeight//delegate.height*3//units.gu(30)
                //clip: true
                delegate:ListItemWithActions
                {
                    id: mapsItem
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
                            width: units.gu(5)
                            height: width
                        }
                    }


                }

            }
            Label{
                text: "<b>Select map to download:</b>"
                width: parent.width
            }

            ListView {
                property int downloadMapIndex: -1
                id: downloadsView

                model: downloadsListModel
                width: parent.width
                //anchors.fill: parent
                height: contentHeight
                //clip: true
                delegate:ListItemWithActions
                {
                    id: downloadsItem

                    onItemClicked: {
                        downloadsView.downloadMapIndex = index;
                        download.text = "Download " + model.name;
                        download.visible = true;
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
                            width: units.gu(5)
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
                    progressbar.value = nPercentage;

                }
                onDownloadComplete:
                {
                    if(mainFrame.currentFileIndex < 20)
                    {
                        var name = downloadsListModel.get(downloadsView.downloadMapIndex);
                        downloadmanager.download(downloadUrl+name+"/"+mainFrame.getNextFilename(), downloadFolder);
                    }
                    else
                    {
                        download.enabled = true;
                        progressItem.visible = false;
                        pause.visible = false;
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
                text: "Download"
                visible: false
                width: parent.width
                onClicked:
                {
                    progressItem.visible = true;
                    var name = downloadsListModel.get(downloadsView.downloadMapIndex);
                    downloadmanager.downloadFolder = mapsModel.getPreferredDownloadDir()+"/"+name;
                    console.log("Download location: "+mapsModel.getPreferredDownloadDir()+"/"+name);
                    download.enabled = false;
                    mainFrame.currentFileIndex = -1;
                    pause.visible = true;
                    downloadmanager.download(downloadmanager.downloadUrl+name+"/"+mainFrame.getNextFilename(), downloadmanager.downloadFolder);
                }
            }
            Button {
                id: pause
                text: "Pause Download"
                width: parent.width
                visible: false
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

            Item{
                id: progressItem
                visible: false;
                width: parent.width;
                height: progressbar.height+l1.height+l2.height+progressbarFiles.height
                Column{
                    height: parent.height
                    width: parent.width
                    Label{
                        id: l1
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
                        id: l2
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


            Button {
                id: ok
                text: "Close"
                width: parent.width
                onClicked: {
                    map.reopenMap();
                    close();
                }
            }
        }
    }
}
