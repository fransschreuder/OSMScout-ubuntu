import QtQuick 2.3
import Ubuntu.Components 1.1
//import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
//import QtQuick.Controls.Styles 1.2
import QtQuick.Window 2.0

import QtPositioning 5.3
import QtSystemInfo 5.0
import QtMultimedia 5.0
import net.sf.libosmscout.map 1.0

import "custom"
Window{
    //Avoid screen from going blank after some time...
    ScreenSaver { screenSaverEnabled: false }
    LocationListModel {
        id: suggestionModel
    }
    width: units.gu(100)
    height: units.gu(160)

    id: mainWindow
    //objectName: "main"
    title: "OSMScout"
    visible: true
    property double oldX: 0;
    property double oldY: 0;
    property double previousX: 0;
    property double previousY: 0;
    property bool followMe: true;
    property string routeFrom: qsTr("<current position>");
    property string routeTo: "";
    property Location routeFromLoc;
    property Location routeToLoc;
    property bool allowRecalculation: true;

    function openRoutingDialog() {
        var component = Qt.createComponent("RoutingDialog.qml")
        var dialog = component.createObject(mainWindow, {})
        positionSource.processUpdateEvents=false;
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
        //navigation.visible = false;
        positionSource.processUpdateEvents=false;
    }

    function onDialogClosed() {
        menu.visible = true;
        //navigation.visible = true;
        //timer.running = true;
        map.focus = true;
        positionSource.processUpdateEvents=true;
    }
    Timer{
        id: followMeTimer
        repeat: false
        interval: 30000
        running: false
        onTriggered: {
            console.log("Timer expired");
            followMe = true;
        }
    }
    Timer{
        id: stopRecalucationTimer
        repeat: false
        interval: 10000
        running: false
        onTriggered: {
            console.log("Timer expired");
            allowRecalculation = true;
        }
    }
    property int lastPlayedIndex1: -1;
    property int lastPlayedIndex2: -1;
    property var nextAudio: soundstraight;
    property var distAudio: sound50m;
    function playRouteInstruction(distance, icon, index)
    {
        var firstDistance;
        var secondDistance;
        if(index!==lastPlayedIndex1 || index!==lastPlayedIndex2)
        {
            if(positionSource.position.speed*3.6 > 80)
            {
                distAudio = sound800m;
                firstDistance = 0.800;
                secondDistance = 0.200;
            }
            else if(positionSource.position.speed*3.6 > 50)
            {
                distAudio = sound200m;
                firstDistance = 0.200;
                secondDistance = 0.050;
            }
            else
            {
                distAudio = sound50m;
                firstDistance = 0.050;
                secondDistance = 0.015;
            }


            switch(icon)
            {
                case "routeLeft.svg":
                    nextAudio = soundgoleft;break;
                case "routeRight.svg":
                    nextAudio = soundgoright;break;
                case "routeFinish.svg":
                    nextAudio = soundfinish;break;
                case "routeMotorwayEnter.svg":
                    nextAudio = soundmwenter;break;
                case "routeMotorwayLeave.svg":
                    nextAudio = soundmwleave; break;
                case "routeRoundabout1.svg":
                    nextAudio = soundround1; break;
                case "routeRoundabout2.svg":
                    nextAudio = soundround2; break;
                case "routeRoundabout3.svg":
                    nextAudio = soundround3; break;
                case "routeRoundabout4.svg":
                    nextAudio = soundround4; break;
                case "routeRoundabout5.svg":
                    nextAudio = soundround5; break;
                case "routeSharpLeft.svg":
                    nextAudio = soundsharpleft; break;
                case "routeSharpRight.svg":
                    nextAudio = soundsharpright; break;
                case "routeSlightlyLeft.svg":
                    nextAudio = soundslightlyleft; break;
                case "routeSlightlyRight.svg":
                    nextAudio = soundslightlyright; break;
                case "routeStraight.svg":
                    nextAudio = soundstraight; break;
                default: return;
            }
            if(distance <= firstDistance && distance> secondDistance
                    && index!==lastPlayedIndex1 &&index!==lastPlayedIndex2)
            {
                if(distAudio.hasAudio && nextAudio.hasAudio)
                {
                    lastPlayedIndex1=index;
                    distAudio.play();
                }
            }

            if(distance <= secondDistance
                    && index!==lastPlayedIndex2)
            {
                if(nextAudio.hasAudio)
                {
                    lastPlayedIndex2=index;
                    nextAudio.play();
                }
            }
        }
    }


    Audio {
        id: sound200m;
        source: "../sounds/200m.mp3"
        onStopped: {
            nextAudio.play();
        }
    }
    Audio {
        id: sound50m;
        source: "../sounds/50m.mp3"
        onStopped: {
            nextAudio.play();
        }
    }
    Audio {
        id: sound800m;
        source: "../sounds/800m.mp3"
        onStopped: {
            nextAudio.play();
        }
    }
    Audio { id: soundfinish;        source: "../sounds/finish.mp3" }
    Audio { id: soundgoleft;        source: "../sounds/goleft.mp3" }
    Audio { id: soundgoright;       source: "../sounds/goright.mp3" }
    Audio { id: soundmwenter;       source: "../sounds/motorwayenter.mp3" }
    Audio { id: soundmwleave;       source: "../sounds/motorwayleave.mp3" }
    Audio { id: soundround1;        source: "../sounds/roundabout1.mp3" }
    Audio { id: soundround2;        source: "../sounds/roundabout2.mp3" }
    Audio { id: soundround3;        source: "../sounds/roundabout3.mp3" }
    Audio { id: soundround4;        source: "../sounds/roundabout4.mp3" }
    Audio { id: soundround5;        source: "../sounds/roundabout5.mp3" }
    Audio { id: soundsharpleft;     source: "../sounds/sharpleft.mp3" }
    Audio { id: soundsharpright;    source: "../sounds/sharpright.mp3" }
    Audio { id: soundslightlyleft;  source: "../sounds/slightlyleft.mp3" }
    Audio { id: soundslightlyright; source: "../sounds/slightlyright.mp3" }
    Audio { id: soundstraight;      source: "../sounds/straight.mp3" }

    PositionSource {
        id: positionSource
        property bool processUpdateEvents: true
        property bool awayFromRoute: false

        active: true

        onValidChanged: {
            console.log("Positioning is " + valid)
            console.log("Last error " + sourceError)

            for (var m in supportedPositioningMethods) {
                console.log("Method " + m)
            }
        }

        onPositionChanged: {
            console.log("Position changed:")
            if(!processUpdateEvents) return;
            if (position.latitudeValid) {
                var routeStep = routingModel.getNext(positionSource.position.coordinate.latitude, positionSource.position.coordinate.longitude);
                awayFromRoute = routingModel.getAwayFromRoute();
                if(reCalculatingMessage.visible === true) awayFromRoute=true;
                if(awayFromRoute===true)
                {
                    if(allowRecalculation===false)
                    {
                        awayFromRoute = false;
                        return;
                    }
                    if(reCalculatingMessage.visible === false)
                    {
                        reCalculatingMessage.visible = true;
                        reCalculatingMessage.update();
                        return; ///will continue on next gps update
                    }
                    if(map.isRendering())return;
                    processUpdateEvents = false;
                    console.log("Recalculating route");
                    var lat = positionSource.position.coordinate.latitude;
                    var lon = positionSource.position.coordinate.longitude;
                    var locString = (lat>0?"N":"S")+Math.abs(lat)+" "+(lon>0?"E":"W")+Math.abs(lon);
                    var tempLoc = routeFromLoc; // temporarily store current start location in case recalculation fails.
                    suggestionModel.setPattern(locString);
                    if (suggestionModel.count>=1) {
                        routeFromLoc=suggestionModel.get(0);
                    }
                    if(routeToLoc && routeFromLoc){
                        console.log("Old route had "+routingModel.count+" points");
                        routingModel.setStartAndTarget(routeFromLoc,
                                                       routeToLoc);
                        console.log("New route has "+routingModel.count+" points");
                        if(routingModel.count === 0)
                        {
                            console.log("Recalculation failed, restore old route...");
                            routeFromLoc = tempLoc;
                            routingModel.setStartAndTarget(routeFromLoc,
                                                           routeToLoc);

                        }
                    }
                    reCalculatingMessage.visible = false;
                    reCalculatingMessage.update();
                    allowRecalculation = false;
                    stopRecalucationTimer.start();
                    processUpdateEvents = true;
                    return;
                }
                awayFromRoute = false;
                playRouteInstruction(routeStep.dCurrentDistance, routeStep.icon, routeStep.index);
                routeIcon.source = "qrc:///pics/"+routeStep.icon;
                routeDistance.text = routeStep.currentDistance;
                routeDist.text = routeStep.targetDistance;
                routeTime.text = routeStep.targetTime;
                //routeInstructionText.text = "<b>"+ routeStep.description + "</b><br/>"+routeStep.distance;
                positionCursor.x = map.geoToPixelX(positionSource.position.coordinate.longitude, positionSource.position.coordinate.latitude)-positionCursor.width/2;
                positionCursor.y = map.geoToPixelY(positionSource.position.coordinate.longitude, positionSource.position.coordinate.latitude)-positionCursor.height/2;

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
            Rectangle{
                id: precisionCircle
                x: positionCursor.x+positionCursor.width/2-width/2
                y: positionCursor.y+positionCursor.height/2-height/2
                height: map.distanceToPixels(positionSource.position.horizontalAccuracy)/2
                width: height
                color: UbuntuColors.blue
                opacity: 0.2
                radius: width/2

            }

            Item{
                id: positionCursor
                x: positionSource.position.latitudeValid?map.geoToPixelX(positionSource.position.coordinate.longitude, positionSource.position.coordinate.latitude)-width/2:0
                y: positionSource.position.latitudeValid?map.geoToPixelY(positionSource.position.coordinate.longitude, positionSource.position.coordinate.latitude)-height/2:0

                width: units.gu(4)
                height: units.gu(4)
                Image {
                    width: units.gu(4)
                    height: units.gu(4)
                    anchors.centerIn: parent
                    source: "qrc:///pics/route.svg"
                    rotation: positionSource.position.directionValid?positionSource.position.direction:0
                }
                /*Icon{
                    visible: positionSource.position.latitudeValid
                    anchors.fill: parent
                    name: "location"

                }*/
            }




            PinchArea{
                id: pinch
                anchors.fill: parent
                //pinch.dragAxis: Pinch.XAndYAxis
                onPinchStarted: {
                    console.log("Pinch started" );
                    positionSource.processUpdateEvents = false;
                }
                onPinchUpdated: {
                    if(!positionSource.awayFromRoute)
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
                    if(followMe)
                    {
                        followMe = false;
                        followMeTimer.start(); //re-enable after 30 seconds
                    }
                    map.zoom(pinch.scale);//, pinch.startCenter.x-pinch.center.x, pinch.startCenter.y-pinch.center.y);
                    positionSource.processUpdateEvents = true;
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
                        positionSource.processUpdateEvents = false;

                    }

                    onPositionChanged:
                    {
                        if(!positionSource.awayFromRoute)
                            map.moveQuick(oldX - mouse.x, oldY - mouse.y);

                        positionCursor.x += (mouse.x - previousX);
                        positionCursor.y += (mouse.y - previousY);

                        previousX = mouse.x;
                        previousY = mouse.y;
                    }

                    onReleased:
                    {
                        positionSource.processUpdateEvents = true;
                        map.move(oldX - mouse.x, oldY - mouse.y);
                        if(Math.abs(oldX - mouse.x)>20||Math.abs(oldY - mouse.y)>20)
                        {
                            if(followMe)
                            {
                                followMe = false;
                                followMeTimer.start(); //re-enable after 30 seconds
                            }
                        }
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
                height: statsCol.height

                id: routingInstructions
                Rectangle {
                    width: parent.width
                    height: parent.height
                    color: "black"
                    opacity: 0.5
                }
                Row{
                    id: routingRow
                    width: parent.width
                    height: parent.height
                    Image{
                        id: routeIcon
                        width: parent.height
                        height: parent.height
                        source: "qrc:///pics/route.svg"
                    }
                    Label{
                        id: routeDistance
                        anchors.verticalCenter: parent.verticalCenter
                        fontSize: "x-large"
                        color: "white"
                    }
                    Item{
                        id: spacer
                        height: parent.height
                        width: parent.width-(routeIcon.width + routeDistance.width + statsCol.width)
                    }

                    /*Label{
                        id: routeInstructionText
                        anchors.left: parent.left
                        anchors.top: parent.top
                        text: "<b>No route</b>"
                        color: "white"
                    }*/
                    Column{
                        id: statsCol
                        Label{
                            id: routeSpeed
                            text: positionSource.position.speedValid?(positionSource.position.speed*3.6).toFixed(2)+" km/h":" "
                            color: "white"
                        }
                        Label{
                            id: routeDist
                            text: " "
                            color: "white"
                        }
                        Label{
                            id: routeTime
                            text: " "
                            color: "white"
                        }
                    }

                }
            }
            Rectangle {
                id: reCalculatingMessage
                anchors {
                    horizontalCenter: map.horizontalCenter
                    verticalCenter: map.verticalCenter
                }
                width: map.width*0.66
                height: recalcMsg.height*5
                color: UbuntuColors.orange
                visible: false
                Label {
                    id: recalcMsg
                    text: qsTr("Recalculating route")
                    anchors.centerIn: parent
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
                    text: qsTr(" © OpenStreetMap contributors")
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
