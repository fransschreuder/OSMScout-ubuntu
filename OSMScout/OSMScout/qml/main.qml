import QtQuick 2.3
import Ubuntu.Components 1.1
//import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
//import QtQuick.Controls.Styles 1.2
import QtQuick.Window 2.0

import QtPositioning 5.3

import net.sf.libosmscout.map 1.0

import "custom"
Window{
    width: units.gu(100)
    height: units.gu(160)

    id: mainWindow
    //objectName: "main"
    title: "OSMScout"
    visible: true
    property int oldX: 0;
    property int oldY: 0;
    property bool followMe: true;

    function openRoutingDialog() {
        var component = Qt.createComponent("RoutingDialog.qml")
        var dialog = component.createObject(mainWindow, {})
        positionSource.stop();
        dialog.opened.connect(onDialogOpened)
        dialog.closed.connect(onDialogClosed)
        dialog.open()
    }

    function openAboutDialog() {
        var component = Qt.createComponent("AboutDialog.qml")
        var dialog = component.createObject(mainWindow, {})

        dialog.opened.connect(onDialogOpened)
        dialog.closed.connect(onDialogClosed)
        dialog.open()
    }

    function openDownloadMapDialog() {
        var component = Qt.createComponent("DownloadMapDialog.qml")
        var dialog = component.createObject(mainWindow, {})

        dialog.opened.connect(onDialogOpened)
        dialog.closed.connect(onDialogClosed)
        dialog.open()
    }

    function showLocation(location) {
        map.showLocation(location)
    }

    function onDialogOpened() {
        menu.visible = false
        navigation.visible = false
    }

    function onDialogClosed() {
        menu.visible = true
        navigation.visible = true

        map.focus = true
        positionSource.start();
    }

    PositionSource {
        id: positionSource

        active: true

        onValidChanged: {
            console.log("Positioning is " + valid)
            console.log("Last error " + sourceError)

            for (var m in supportedPositioningMethods) {
                console.log("Method " + m)
            }
        }

        onPositionChanged: {
            //console.log("Position changed:")

            if (position.latitudeValid) {
                //console.log("  latitude: " + position.coordinate.latitude)
                if(followMe==true)
                {
                    map.showCoordinates(position.coordinate.latitude, position.coordinate.longitude);
                }
            }

            if (position.longitudeValid) {
                //console.log("  longitude: " + position.coordinate.longitude)
            }

            if (position.altitudeValid) {
                //console.log("  altitude: " + position.coordinate.altitude)
            }

            if (position.speedValid) {
                //console.log("  speed: " + position.speed)
            }

            if (position.horizontalAccuracyValid) {
                //console.log("  horizontal accuracy: " + position.horizontalAccuracy)
            }

            if (position.verticalAccuracyValid) {
                //console.log("  vertical accuracy: " + position.verticalAccuracy)
            }
        }
    }

    GridLayout {
        id: content
        anchors.fill: parent

        Map {
            id: map
            Layout.fillWidth: true
            Layout.fillHeight: true
            focus: true

            function updateFreeRect() {
                searchDialog.desktopFreeSpace =  Qt.rect(Theme.horizSpace,
                                                         Theme.vertSpace+searchDialog.height+Theme.vertSpace,
                                                         map.width-2*Theme.horizSpace,
                                                         map.height-searchDialog.y-searchDialog.height-3*Theme.vertSpace)
            }

            onWidthChanged: {
                updateFreeRect()
            }

            onHeightChanged: {
                updateFreeRect()
            }

            Keys.onPressed: {
                if (event.key === Qt.Key_Plus) {
                    map.zoomIn(2.0)
                    event.accepted = true
                }
                else if (event.key === Qt.Key_Minus) {
                    map.zoomOut(2.0)
                    event.accepted = true
                }
                else if (event.key === Qt.Key_Up) {
                    map.up()
                    event.accepted = true
                }
                else if (event.key === Qt.Key_Down) {
                    map.down()
                    event.accepted = true
                }
                else if (event.key === Qt.Key_Left) {
                    if (event.modifiers & Qt.ShiftModifier) {
                        map.rotateLeft();
                    }
                    else {
                        map.left();
                    }
                    event.accepted = true
                }
                else if (event.key === Qt.Key_Right) {
                    if (event.modifiers & Qt.ShiftModifier) {
                        map.rotateRight();
                    }
                    else {
                        map.right();
                    }
                    event.accepted = true
                }
                else if (event.modifiers===Qt.ControlModifier &&
                         event.key === Qt.Key_F) {
                    searchDialog.focus = true
                    event.accepted = true
                }
                else if (event.modifiers===Qt.ControlModifier &&
                         event.key === Qt.Key_R) {
                    openRoutingDialog()
                    event.accepted = true
                }
            }

            Item{
                id: positionCursor
                x: positionSource.position.latitudeValid?map.geoToPixelX(positionSource.position.coordinate.longitude, positionSource.position.coordinate.latitude)-width/2:0
                y: positionSource.position.latitudeValid?map.geoToPixelY(positionSource.position.coordinate.longitude, positionSource.position.coordinate.latitude)-height:0

                width: units.gu(3)
                height: units.gu(3)
                Icon{
                    visible: positionSource.position.latitudeValid
                    anchors.fill: parent
                    name: "location"

                }
            }


            PinchArea{
                id: pinch
                anchors.fill: parent
                pinch.dragAxis: Pinch.XAndYAxis
                onPinchStarted: {
                    console.log("Pinch started" );
                }
                onPinchUpdated: {
                    map.zoomQuick(pinch.scale);
                    map.moveQuick(pinch.startCenter.x-pinch.center.x, pinch.startCenter.y-pinch.center.y);
                    positionCursor.update;
                }

                onPinchFinished: {
                    console.log(pinch.center.x + " " + pinch.center.y);
                    console.log(pinch.scale);
                    positionCursor.update;
                    followMe = false;
                    map.move(pinch.startCenter.x-pinch.center.x, pinch.startCenter.y-pinch.center.y);
                    if(pinch.scale<1)
                    {
                        map.zoomOut(1/pinch.scale);
                    }
                    else
                    {
                        map.zoomIn(pinch.scale);
                    }

                }
                MouseArea{

                    id: mouse
                    anchors.fill: parent
                    onPressed:
                    {
                        oldX = mouse.x;
                        oldY = mouse.y;
                    }

                    onPositionChanged:
                    {
                        map.moveQuick(oldX - mouse.x, oldY - mouse.y);
                        positionCursor.update;
                        /*oldX = mouse.x;
                        oldY = mouse.y;*/



                    }

                    onReleased:
                    {
                        map.move(oldX - mouse.x, oldY - mouse.y);
                        if(Math.abs(oldX - mouse.x)>20||Math.abs(oldY - mouse.y)>20)
                            followMe = false;
                        oldX = mouse.x;
                        oldY = mouse.y;
                        positionCursor.update;
                    }
                }

            }

            SearchDialog {
                id: searchDialog
                y: Theme.vertSpace
                width: parent.width - 2* Theme.horizSpace
                height: units.gu(4)
                anchors.horizontalCenter: parent.horizontalCenter
                desktopFreeSpace:  Qt.rect(Theme.horizSpace,Theme.vertSpace+searchDialog.height+Theme.vertSpace,map.width-2*Theme.horizSpace,map.height-searchDialog.y-searchDialog.height-3*Theme.vertSpace)
                desktop: map
                onShowLocation: {
                    map.showLocation(location)
                }
            }

            // Top left column
            ColumnLayout {
                id: menu

                x: Theme.horizSpace
                y: searchDialog.y+ searchDialog.height+Theme.vertSpace

                spacing: Theme.mapButtonSpace

                MapButton {
                    id: routeButton
                    //label: "#"

                    onClicked: {
                        openRoutingDialog()
                    }
                    Image {
                        width: parent.width*0.66
                        height: parent.height*0.66
                        anchors.centerIn: parent
                        source: "qrc:///pics/route.svg"
                    }
                }
                MapButton {
                    id: followButton

                    onClicked: {
                        followMe = !followMe;
                    }
                    iconName: followMe ? "stock_website" : "location"
                }
            }

            // Bottom left column
            ColumnLayout {
                id: info

                x: Theme.horizSpace
                y: parent.height-height-Theme.vertSpace

                spacing: Theme.mapButtonSpace
                MapButton {
                    id: downloadButton
                    iconName: "save"
                    onClicked: {
                        openDownloadMapDialog();
                    }
                }

                MapButton {
                    id: about
                    label: "?"

                    onClicked: {
                        openAboutDialog()
                    }
                }
            }

            Rectangle {
                id: osmCopyright
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                }
                height: units.gu(2)
                width: units.gu(24)
                opacity: 0.7
                Label {
                    text: " © OpenStreetMap contributors"
                    fontSize: "small"
                }
            }

            // Bottom right column
            ColumnLayout {
                id: navigation

                x: parent.width-width-Theme.horizSpace
                y: parent.height-height-Theme.vertSpace*2 - osmCopyright.height

                spacing: Theme.mapButtonSpace

                MapButton {
                    id: zoomIn
                    label: "+"

                    onClicked: {
                        map.zoomIn(2.0)
                    }
                }

                MapButton {
                    id: zoomOut
                    label: "-"

                    onClicked: {
                        map.zoomOut(2.0)
                    }
                }
            }
        }
    }
}
