import QtQuick 2.2

import net.sf.libosmscout.map 1.0
import Ubuntu.Components 1.1

Rectangle {
  id: dialogActionButton
  
  property color contentColor: "lightblue"
  property color contentHoverColor: Qt.darker(contentColor, 1.1)
  property color borderColor: Qt.darker(contentColor, 1.1)
  property color textColor: "black"
  property string iconName: ""
  property alias text: label.text
  
  signal clicked
  
  width: label.implicitWidth+4
  height: label.implicitHeight+4
  color: contentColor
  border.color: borderColor
  border.width: 1
  radius: units.gu(1)

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    
    hoverEnabled: true
    onEntered: {
      parent.color = contentHoverColor
    }
    
    onExited:  {
      parent.color = contentColor
    }
    
    onClicked: {
      parent.clicked()
    }
  }
  
  Text {
    id: label
    font.pixelSize: Theme.textFontSize
    anchors.centerIn: parent
    color: textColor
  }
  Icon {
      name : iconName
      anchors.centerIn: parent
      width: parent.width/2;
      height: parent.height/2;
      color: "#000000"
      visible: iconName.length>0
  }
}
