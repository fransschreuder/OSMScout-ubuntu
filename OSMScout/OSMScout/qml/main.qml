import QtQuick 2.3
import Ubuntu.Components 1.1
//import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
//import QtQuick.Controls.Styles 1.2
import QtQuick.Window 2.0

import QtPositioning 5.3
import QtSystemInfo 5.0

import net.sf.libosmscout.map 1.0

import "custom"
Window{
    //Avoid screen from going blank after some time...
    ScreenSaver { screenSaverEnabled: false }
    width: units.gu(100)
    height: units.gu(160)

    id: mainWindow
    //objectName: "main"
    title: "OSMScout"
    visible: true
    property int oldX: 0;
    property int oldY: 0;
    property int previousX: 0;
    property int previousY: 0;
    property bool followMe: true;
    property string routeFrom: "<current position>";
    property string routeTo: "";

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
        menu.visible = false;
        navigation.visible = false;
        positionSource.stop();
    }

    function onDialogClosed() {
        menu.visible = true;
        navigation.visible = true;

        map.focus = true;
        positionSource.start();
    }
    Timer{
        active: true
        onTriggered: {

        }
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
                routingModel.getNext(positionSource.position.coordinate.latitude, positionSource.position.coordinate.longitude);
                positionCursor.x = map.geoToPixelX(positionSource.position.coordinate.longitude, positionSource.position.coordinate.latitude)-positionCursor.width/2;
                positionCursor.y = map.geoToPixelY(positionSource.position.coordinate.longitude, positionSource.position.coordinate.latitude)-positionCursor.height;

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

            /*Keys.onPressed: {
                if (event.key === Qt.Key_Plus) {
                    map.zoom(2.0)
                    event.accepted = true
                }
                else if (event.key === Qt.Key_Minus) {
                    map.zoom(0.5)
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
            }*/

            RoutingListModel {
                id: routingModel
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
                //pinch.dragAxis: Pinch.XAndYAxis
                onPinchStarted: {
                    console.log("Pinch started" );
                }
                onPinchUpdated: {
                    map.zoomQuick(pinch.scale);
                    //map.moveQuick(pinch.startCenter.x-pinch.center.x, pinch.startCenter.y-pinch.center.y);
                    var hw = map.width/2;
                    var hh = map.height/2;
                    positionCursor.x = (positionCursor.x - hw) +(positionCursor.x - hw)/(pinch.scale/pinch.previousScale);
                    positionCursor.y = (positionCursor.y - hh) +(positionCursor.y - hh)/(pinch.scale/pinch.previousScale);
                    //positionCursor.x += (pinch.center.x - pinch.previousCenter.x)/(pinch.scale/pinch.previousScale);
                    //positionCursor.y += (pinch.center.y - pinch.previousCenter.y)/(pinch.scale/pinch.previousScale);


                }

                onPinchFinished: {
                    //console.log(pinch.center.x + " " + pinch.center.y);
                    //console.log(pinch.scale);
                    followMe = false;
                    map.zoom(pinch.scale);//, pinch.startCenter.x-pinch.center.x, pinch.startCenter.y-pinch.center.y);

                }
                MouseArea{

                    id: mouse
                    anchors.fill: parent
                    onPressed:
                    {
                        oldX = mouse.x;
                        oldY = mouse.y;
                        previousX = mouse.x;
                        previousY = mouse.y;

                    }

                    onPositionChanged:
                    {
                        map.moveQuick(oldX - mouse.x, oldY - mouse.y);

                        positionCursor.x += (mouse.x - previousX);
                        positionCursor.y += (mouse.y - previousY);

                        previousX = mouse.x;
                        previousY = mouse.y;
                    }

                    onReleased:
                    {
                        map.move(oldX - mouse.x, oldY - mouse.y);
                        if(Math.abs(oldX - mouse.x)>20||Math.abs(oldY - mouse.y)>20)
                            followMe = false;
                        oldX = mouse.x;
                        oldY = mouse.y;
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

            /*// Bottom left column
            ColumnLayout {
                id: info

                x: Theme.horizSpace
                y: parent.height-height-Theme.vertSpace

                spacing: Theme.mapButtonSpace

            }*/
            Item{
                anchors {
                    left: parent.left
                    bottom: parent.bottom
                }
                width: parent.width
                height: units.gu(6)

                id: routingInstructions
                Rectangle {
                    anchors.fill: parent
                    color: "black"
                    opacity: 0.5
                }
                Row{
                    anchors.fill: parent
                    Label{
                        id: routInstructionText
                        anchors.left: parent.left
                        anchors.top: parent.top
                        text: "<b>No route</b>"
                        color: "white"
                    }
                    Label{
                        anchors.right: parent.right
                        anchors.top: parent.top
                        text: positionSource.position.speedValid?(positionSource.position.speed*3.6).toFixed(2)+" km/h":""
                        color: "white"
                    }

                }
            }


            Rectangle {
                id: osmCopyright
                anchors {
                    right: parent.right
                    bottom: routingInstructions.top
                }
                height: copyLabel.width; //units.gu(2)
                width: copyLabel.height; //units.gu(24)
                opacity: 0.5
                Label {
                    anchors.centerIn: parent
                    id: copyLabel
                    rotation: 270
                    text: " © OpenStreetMap contributors"
                    fontSize: "small"
                }
            }

            /*// Bottom right column
            ColumnLayout {
                id: navigation

                x: parent.width-width-Theme.horizSpace
                y: parent.height-height-Theme.vertSpace*2 - osmCopyright.height

                spacing: Theme.mapButtonSpace

                MapButton {
                    id: zoomIn
                    label: "+"

                    onClicked: {
                        map.zoom(2.0)
                    }
                }

                MapButton {
                    id: zoomOut
                    label: "-"

                    onClicked: {
                        map.zoom(0.5)
                    }
                }
            }*/
        }
    }
}
