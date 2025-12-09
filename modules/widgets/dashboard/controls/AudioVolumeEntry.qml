pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import qs.modules.theme
import qs.modules.components
import qs.modules.services
import qs.config

Item {
    id: root

    required property PwNode node
    property string icon: ""
    property bool isMainDevice: false

    implicitHeight: 48
    implicitWidth: parent?.width ?? 300

    PwObjectTracker {
        objects: [root.node]
    }

    readonly property bool isMuted: root.node?.audio?.muted ?? false
    readonly property real volume: root.node?.audio?.volume ?? 0
    property real lastSetVolume: volume

    RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        spacing: 8

        // Mute button with icon
        Button {
            id: muteButton
            flat: true
            implicitWidth: 36
            implicitHeight: 36
            Layout.preferredWidth: 36
            Layout.maximumWidth: 36
            Layout.fillWidth: false

            background: StyledRect {
                variant: muteButton.hovered ? "focus" : "common"
                radius: Styling.radius(4)
            }

            contentItem: Item {
                Text {
                    anchors.centerIn: parent
                    text: {
                        if (root.icon) return root.icon;
                        // For app nodes, try to get an appropriate icon
                        return Icons.speakerHigh;
                    }
                    font.family: Icons.font
                    font.pixelSize: 18
                    color: root.isMuted ? Colors.outline : Colors.overBackground
                    opacity: root.isMuted ? 0.5 : 1

                    Behavior on opacity {
                        enabled: Config.animDuration > 0
                        NumberAnimation { duration: Config.animDuration / 2 }
                    }
                }

                // Mute indicator overlay
                Text {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: -4
                    visible: root.isMuted
                    text: Icons.cancel
                    font.family: Icons.font
                    font.pixelSize: 12
                    color: Colors.error
                }
            }

            onClicked: {
                if (root.node?.audio) {
                    root.node.audio.muted = !root.node.audio.muted;
                }
            }

            StyledToolTip {
                visible: muteButton.hovered
                text: root.isMainDevice 
                    ? (root.isMuted ? "Unmute" : "Mute")
                    : Audio.appNodeDisplayName(root.node)
            }
        }

        // Volume slider
        StyledSlider {
            id: volumeSlider
            Layout.fillWidth: true
            Layout.preferredHeight: 24
            value: root.volume
            scroll: false
            progressColor: {
                if (root.isMuted) return Colors.outline;
                if (Audio.protectionTriggered && root.isMainDevice) return Colors.warning;
                return Colors.primary;
            }

            onValueChanged: {
                if (root.node?.audio && Math.abs(value - root.volume) > 0.001) {
                    // Use protected volume setter
                    Audio.setNodeVolume(root.node, value);
                }
            }

            Behavior on progressColor {
                enabled: Config.animDuration > 0
                ColorAnimation { duration: Config.animDuration / 2 }
            }
        }

        // Volume percentage with protection indicator
        RowLayout {
            Layout.preferredWidth: 50
            Layout.maximumWidth: 50
            Layout.fillWidth: false
            spacing: 4

            // Protection indicator
            Text {
                visible: Audio.protectionTriggered && root.isMainDevice
                text: Icons.shieldCheck
                font.family: Icons.font
                font.pixelSize: 12
                color: Colors.warning

                StyledToolTip {
                    visible: parent.visible && protectionIndicatorMa.containsMouse
                    text: "Volume protection active"
                }

                MouseArea {
                    id: protectionIndicatorMa
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }

            Text {
                text: `${Math.round(root.volume * 100)}%`
                font.family: Config.theme.font
                font.pixelSize: Config.theme.fontSize - 2
                color: Colors.overSurfaceVariant
                horizontalAlignment: Text.AlignRight
                Layout.fillWidth: true
            }
        }
    }
}
