import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Widgets
import qs.modules.theme
import qs.config

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

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 150
                        color: Colors.surface
                        radius: Config.roundness > 0 ? Config.roundness + 4 : 0
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: width
                        color: Colors.surface
                        radius: Config.roundness > 0 ? Config.roundness + 4 : 0
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 150
                        color: Colors.surface
                        radius: Config.roundness > 0 ? Config.roundness + 4 : 0
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Colors.surface
            radius: Config.roundness > 0 ? Config.roundness + 4 : 0
        }
    }
}
