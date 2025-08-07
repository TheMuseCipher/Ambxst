import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.modules.bar.workspaces
import qs.modules.theme
import qs.modules.bar.clock
import qs.modules.bar.systray
import qs.modules.widgets.launcher
import qs.modules.corners
import qs.config

PanelWindow {
    id: panel

    anchors {
        top: true
        left: true
        right: true
        // bottom: true
    }

    color: "transparent"

    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    exclusiveZone: Config.bar.showBackground ? 44 : 40
    exclusionMode: ExclusionMode.Ignore
    implicitHeight: 44 + Config.roundness + 64
    mask: Region {
        width: panel.width
        height: 44
    }

    Rectangle {
        id: bar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        implicitHeight: 44
        color: "transparent"

        Rectangle {
            id: barBg
            anchors.fill: parent
            property color bgColor: Qt.rgba(
              Colors.adapter.surfaceContainerLowest.r,
              Colors.adapter.surfaceContainerLowest.g,
              Colors.adapter.surfaceContainerLowest.b,
              Config.bar.bgOpacity
            )
            color: Config.bar.showBackground ? bgColor : "transparent"

            RoundCorner {
                id: topLeft
                size: Config.roundness > 0 ? Config.roundness + 4 : 0
                anchors.left: parent.left
                anchors.top: parent.bottom
                corner: RoundCorner.CornerEnum.TopLeft
                color: parent.color
            }

            RoundCorner {
                id: topRight
                size: Config.roundness > 0 ? Config.roundness + 4 : 0
                anchors.right: parent.right
                anchors.top: parent.bottom
                corner: RoundCorner.CornerEnum.TopRight
                color: parent.color
            }
        }

        Rectangle {
            id: barBgShadow
            anchors.fill: barBg
            color: Config.bar.showBackground ? "black" : "transparent"

            layer.enabled: true
            layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: barBgShadow
                maskInverted: true
                maskThresholdMin: 0.75
                shadowEnabled: true
                shadowHorizontalOffset: 0
                shadowVerticalOffset: 0
                shadowBlur: 1
                shadowColor: Colors.adapter.shadow
                shadowOpacity: Config.theme.shadowOpacity
            }

            RoundCorner {
                size: Config.roundness > 0 ? Config.roundness + 4 : 0
                anchors.left: parent.left
                anchors.top: parent.bottom
                corner: RoundCorner.CornerEnum.TopLeft
                color: parent.color
            }

            RoundCorner {
                size: Config.roundness > 0 ? Config.roundness + 4 : 0
                anchors.right: parent.right
                anchors.top: parent.bottom
                corner: RoundCorner.CornerEnum.TopRight
                color: parent.color
            }
        }

        // Left side of bar
        RowLayout {
            id: leftSide
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 4
            spacing: 4

            LauncherButton {
                id: launcherButton
            }

            Workspaces {
                bar: QtObject {
                    property var screen: panel.screen
                }
            }

            OverviewButton {
                id: overviewButton
            }
        }

        // Right side of bar
        RowLayout {
            id: rightSide
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 4
            spacing: 4

            SysTray {
                bar: panel
            }

            Clock {
                id: clockComponent
            }
        }
    }
}
