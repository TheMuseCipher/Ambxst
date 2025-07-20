import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import "../theme"
import "../workspaces"

Button {
    id: root

    implicitWidth: 36
    implicitHeight: 36

    background: StyledContainer {
        color: root.pressed ? Colors.primary : (root.hovered ? Colors.surfaceBright : Colors.background)

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    contentItem: Text {
        text: "󰈸"
        font.family: Styling.defaultFont
        font.pixelSize: 20
        color: root.pressed ? Colors.background : Colors.primary
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    onClicked: {
        // Toggle launcher
        GlobalStates.launcherOpen = !GlobalStates.launcherOpen;
    }

    ToolTip.visible: false
    ToolTip.text: "Open Application Launcher"
    ToolTip.delay: 1000
}
