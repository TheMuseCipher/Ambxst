import QtQuick
import QtQuick.Controls
import Quickshell.Services.Notifications
import qs.modules.theme

Button {
    id: root
    property string buttonText: ""
    property var urgency: NotificationUrgency.Normal

    text: buttonText

    background: Rectangle {
        color: root.pressed ? Colors.adapter.primary : (root.hovered ? Colors.surfaceContainerHighest : Colors.surfaceBright)
        border.color: (root.urgency == NotificationUrgency.Critical) ? Colors.adapter.error : Colors.adapter.outline
        border.width: 0
        radius: 8

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    contentItem: Text {
        text: root.text
        font.family: Styling.defaultFont
        font.pixelSize: 14
        color: (root.urgency == NotificationUrgency.Critical) ? "#d32f2f" : "#424242"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
