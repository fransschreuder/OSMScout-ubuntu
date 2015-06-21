import QtQuick 2.2
import QtGraphicalEffects 1.0

import net.sf.libosmscout.map 1.0
import Ubuntu.Components 1.1

Rectangle {
  id: mapButton
  
  property color defaultColor: UbuntuColors.warmGrey
  property color hoverColor: UbuntuColors.orange
  property string label
  property string iconName

  property alias font: mapButtonLabel.font

  signal clicked
  radius: units.gu(1)
  width: units.gu(6)
  height: units.gu(6)
  color: hoverColor //defaultColor
  opacity: 0.8

  MouseArea {
    id: mapButtonMouseArea
    anchors.fill: parent
    
    hoverEnabled: true
    /*onEntered: {
      parent.color = hoverColor
    }
    
    onExited:  {
      parent.color = defaultColor
    }*/
    
    onClicked: {
      parent.clicked()
    }
  }
  
  Text {
    id: mapButtonLabel
    anchors.centerIn: parent
    color: "black"
    text: label
  }
  Icon{
      width: parent.width/2
      height: parent.height/2
      anchors.centerIn: parent
      name: mapButton.iconName
      color: "#000000"
      visible: iconName.length>0
  }

}
