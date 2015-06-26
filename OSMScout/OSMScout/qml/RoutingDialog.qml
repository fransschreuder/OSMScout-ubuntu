import QtQuick 2.2
import QtQuick.Layouts 1.1

import net.sf.libosmscout.map 1.0
import Ubuntu.Components 1.1
import Qt.labs.settings 1.0
import "custom"

MapDialog {
    id: dialog

    fullscreen: true
    label: qsTr("Route...")



    content : ColumnLayout {
        id: mainFrame

        Settings{
            id: routeSettings
            category: "routing"
            property int vehicle: 3 //Car, Bicycle=2
        }

        Layout.fillWidth: true
        Layout.fillHeight: true

        GridLayout {
            Layout.fillWidth: true
            columns: 2

            Text {
                id: startText
                Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline

                text: qsTr("Start:")
                font.pixelSize: Theme.textFontSize
            }

            LocationEdit {
                text: mainWindow.routeFrom
                location: mainWindow.routeFromLoc
                width: targetInput.width
                height: units.gu(4)
                id: startInput
                anchors.right: targetInput.right
                horizontalAlignment: TextInput.AlignLeft
            }

            Text {
                id: targetText
                Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline

                text: qsTr("Target:")
                font.pixelSize: Theme.textFontSize
            }

            LocationEdit {
                text: mainWindow.routeTo
                location: mainWindow.routeToLoc
                width: units.gu(32)//parent.width-targetText.width - Theme.horizSpace
                height: units.gu(4)
                id: targetInput
                horizontalAlignment: TextInput.AlignLeft
            }

        }

        Row {
            id: buttonRow
            Layout.fillWidth: true
            spacing: Theme.horizSpace

            Item {
                Layout.fillWidth: true
                implicitWidth: 0
                width: 1
            }

            Button {
                id: route
                text: qsTr("Route")

                onClicked: {
                    startInput.enforceLocationValue()
                    targetInput.enforceLocationValue()

                    if (startInput.location && targetInput.location) {
                        routingModel.setStartAndTarget(startInput.location,
                                                       targetInput.location)
                    }
                    mainWindow.routeTo = targetInput.text;
                    mainWindow.routeToLoc = targetInput.location;
                    mainWindow.routeFrom = startInput.text;
                    mainWindow.routeFromLoc = startInput.location;
                    if(routingModel.count === 0)
                    {
                        noRouteText.visible = true;
                        routeView.visible = false;
                    }
                    else
                    {
                        noRouteText.visible = false;
                        routeView.visible = true;
                    }

                    console.log("routingModel.size: "+ routingModel.count);
                }

            }

            Button {
                id: close
                text: qsTr("Close")

                onClicked: {
                    mainWindow.routeTo = targetInput.text;
                    mainWindow.routeFrom = startInput.text;
                    dialog.close()
                }
            }
            Rectangle
            {
                color: routeSettings.vehicle===3?UbuntuColors.orange:UbuntuColors.lightGrey
                width: close.height
                height: close.height
                radius: units.gu(1)
                Image {
                    id: carButton

                    width: close.height
                    height: close.height

                    source: "qrc:///pics/car.svg"
                    fillMode: Image.PreserveAspectFit
                    horizontalAlignment: Image.AlignHCenter
                    verticalAlignment: Image.AlignVCenter
                    sourceSize.width: close.height
                    sourceSize.height: close.height
                    MouseArea {
                        anchors.fill: carButton

                        onClicked: {
                            routeSettings.vehicle = 3;
                        }
                    }
                }
            }

            Rectangle{
                color: routeSettings.vehicle===2?UbuntuColors.orange:UbuntuColors.lightGrey
                width: close.height
                height: close.height
                radius: units.gu(1)
                Image {
                    id: bikeButton

                    width: close.height
                    height: close.height

                    source: "qrc:///pics/bicycle.svg"
                    fillMode: Image.PreserveAspectFit
                    horizontalAlignment: Image.AlignHCenter
                    verticalAlignment: Image.AlignVCenter
                    sourceSize.width: close.height
                    sourceSize.height: close.height


                    MouseArea {
                        anchors.fill: bikeButton

                        onClicked: {
                            routeSettings.vehicle = 2;
                        }
                    }
                }
            }
            Rectangle{
                color: routeSettings.vehicle===1?UbuntuColors.orange:UbuntuColors.lightGrey
                width: close.height
                height: close.height
                radius: units.gu(1)
                Image {
                    id: footButton

                    width: close.height
                    height: close.height

                    source: "qrc:///pics/foot.svg"
                    fillMode: Image.PreserveAspectFit
                    horizontalAlignment: Image.AlignHCenter
                    verticalAlignment: Image.AlignVCenter
                    sourceSize.width: close.height
                    sourceSize.height: close.height


                    MouseArea {
                        anchors.fill: footButton

                        onClicked: {
                            routeSettings.vehicle = 1;
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true

            border.color: "lightgrey"
            border.width: 1

            Label{
                id: noRouteText
                text: qsTr("No route found")
                visible: false
            }

            ListView {
                id: routeView

                model: routingModel

                anchors.fill: parent

                clip: true

                delegate: Item {
                    id: item

                    anchors.right: parent.right;
                    anchors.left: parent.left;
                    height: text.implicitHeight+5

                    Text {
                        id: text

                        y:2
                        x: 2
                        width: parent.width-4
                        text: label
                        font.pixelSize: Theme.textFontSize
                    }

                    Rectangle {
                        x: 2
                        y: parent.height-2
                        width: parent.width-4
                        height: 1
                        color: "lightgrey"
                    }
                }
            }

            ScrollIndicator {
                flickableArea: routeView
            }
        }
    }
}
