import QtQuick
import QtQuick.Controls
import qs.modules.theme

Button {
    id: root
    property int count: 1
    property bool expanded: false
    property real fontSize: 12

    visible: count > 1
    width: 20
    height: 20

    background: Rectangle {
        color: root.pressed ? Colors.adapter.primary : (root.hovered ? Colors.surfaceBright : Colors.surfaceContainerHigh)
        radius: 10

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    contentItem: Text {
        text: root.expanded ? "−" : "+"
        font.family: Styling.defaultFont
        font.pixelSize: 20
        color: Colors.adapter.overBackground
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
