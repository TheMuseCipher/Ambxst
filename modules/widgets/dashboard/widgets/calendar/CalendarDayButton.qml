import QtQuick
import QtQuick.Layouts
import qs.modules.theme
import qs.config

Rectangle {
    id: button

    required property string day
    required property int isToday
    property bool bold: false

    Layout.fillWidth: true
    Layout.fillHeight: false
    Layout.preferredWidth: 32
    Layout.preferredHeight: 32

    color: (isToday === 1) ? Colors.primary : "transparent"
    radius: Config.roundness > 0 ? Config.roundness - 2 : 0

    Text {
        anchors.fill: parent
        text: day
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.weight: Font.Bold
        font.pixelSize: Config.theme.fontSize
        font.family: Config.defaultFont
        color: (isToday === 1) ? Colors.overPrimary : (isToday === 0) ? Colors.overSurface : Colors.outline

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }
}
