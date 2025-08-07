import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import qs.modules.theme
import qs.modules.globals
import qs.config

Button {
    id: root

    required property string buttonIcon
    required property string tooltipText
    required property var onToggle

    implicitWidth: 36
    implicitHeight: 36

    background: BgRect {
        Behavior on color {
            ColorAnimation {
                duration: Config.animDuration / 2
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: Config.animDuration / 2
            }
        }
    }

    contentItem: Text {
        text: root.buttonIcon
        textFormat: Text.RichText
        font.family: Styling.iconFont
        font.pixelSize: 20
        color: root.pressed ? Colors.background : Colors.adapter.primary
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        Behavior on color {
            ColorAnimation {
                duration: Config.animDuration / 2
            }
        }
    }

    onClicked: root.onToggle()

    ToolTip.visible: false
    ToolTip.text: root.tooltipText
    ToolTip.delay: 1000
}
