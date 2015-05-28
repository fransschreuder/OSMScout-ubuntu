import QtQuick 2.2
import QtQuick.Layouts 1.1

import net.sf.libosmscout.map 1.0
import Ubuntu.Components 1.1

import "custom"

MapDialog {
    id: dialog

    fullscreen: true
    label: "Route..."

    content : ColumnLayout {
        id: mainFrame

        Layout.fillWidth: true
        Layout.fillHeight: true

        GridLayout {
            Layout.fillWidth: true
            columns: 2

            Text {
                id: startText
                Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline

                text: "Start:"
                font.pixelSize: Theme.textFontSize
            }

            LocationEdit {
                width: targetInput.width
                height: units.gu(4)
                id: startInput
                anchors.right: targetInput.right
                horizontalAlignment: TextInput.AlignLeft
            }

            Text {
                id: targetText
                Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline

                text: "Target:"
                font.pixelSize: Theme.textFontSize
            }

            LocationEdit {
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
                text: "Route"

                onClicked: {
                    startInput.enforceLocationValue()
                    targetInput.enforceLocationValue()

                    if (startInput.location && targetInput.location) {
                        routingModel.setStartAndTarget(startInput.location,
                                                       targetInput.location)
                    }
                }
            }

            Button {
                id: close
                text: "Close"

                onClicked: {
                    dialog.close()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true

            border.color: "lightgrey"
            border.width: 1

            RoutingListModel {
                id: routingModel
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
