import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.modules.theme
import qs.modules.components
import qs.config
import "calendar"

Rectangle {
    color: "transparent"
    implicitWidth: 600
    implicitHeight: 300

    RowLayout {
        anchors.fill: parent
        spacing: 8

        NotificationHistory {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        ClippingRectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Config.roundness > 0 ? Config.roundness + 4 : 0

            color: "transparent"

            Flickable {
                anchors.fill: parent
                contentWidth: width
                contentHeight: columnLayout.implicitHeight
                clip: true

                ColumnLayout {
                    id: columnLayout
                    width: parent.width
                    spacing: 8

                    FullPlayer {
                        Layout.fillWidth: true
                        // Layout.preferredHeight: 90
                    }

                    Calendar {
                        Layout.fillWidth: true
                        Layout.preferredHeight: width
                    }

                    PaneRect {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 150
                    }
                }
            }
        }

        PaneRect {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
