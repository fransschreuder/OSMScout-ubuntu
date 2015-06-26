import QtQuick 2.3
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0
import Qt.labs.settings 1.0
import net.sf.libosmscout.map 1.0

Component{



    id: dialog
    Dialog
    {
        Settings {
            id: settings
            property bool metricSystem: (Qt.locale().measurementSystem===Locale.MetricSystem)
            //property bool drivingDirUp: false
            property double fontSize: 1
            property int defaultDownloadFolder: (downloadDirListModel.count-1)
        }
        DownloadDirListModel{
            id: downloadDirListModel
        }

        signal closed()
        id: dialogue
         title: "Settings"
         Grid{
             columns: 2
             spacing: units.gu(1)
             //width: parent.width
             Label{
                 text: qsTr("Use metric system")
             }
             Switch{
                 id: swMetric
                 checked: settings.metricSystem
                 onClicked:
                 {
                     settings.metricSystem = checked;
                 }
             }

             Label{
                 text: qsTr("Font size")
             }
             Slider{
                 id: slFontSize
                 minimumValue: 0.3
                 maximumValue: 4
                 value: settings.fontSize
                 width: units.gu(10)
                 onValueChanged:
                 {
                     settings.fontSize = Math.round(value*10)/10;
                 }
                 function formatValue(v) { return v.toFixed(1) }

             }

         }
         Label{
             text: qsTr("Default download directory")
         }


         OptionSelector{
             delegate: Component{
                 id: selectorDelegate
                 OptionSelectorDelegate{
                    text: model.path
                 }
             }
             model:downloadDirListModel
             onDelegateClicked: {
                 settings.defaultDownloadFolder = index;
                 console.log("Index changed: "+index);
             }
             selectedIndex: settings.defaultDownloadFolder

         }

         Button {
             text: qsTr("Close")
             onClicked: {
                 PopupUtils.close(dialogue);
                 closed();

             }
         }
    }
}
