import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import qs.modules.theme
import qs.modules.services
import qs.modules.components
import qs.config

StyledRect {
    id: root
    variant: "pane"
    Layout.fillHeight: true
    implicitWidth: parent.width
    radius: Styling.radius(0)

    visible: WeatherService.dataAvailable

    // Dynamic gradient based on time of day
    property var dayGradient: Gradient {
        GradientStop { position: 0.0; color: "#87CEEB" }  // Sky blue top
        GradientStop { position: 0.7; color: "#B0E0E6" }  // Powder blue
        GradientStop { position: 1.0; color: "#E0F6FF" }  // Light blue bottom
    }

    property var eveningGradient: Gradient {
        GradientStop { position: 0.0; color: "#1a1a2e" }  // Dark blue top
        GradientStop { position: 0.4; color: "#e94560" }  // Pink/red
        GradientStop { position: 0.7; color: "#f39c12" }  // Orange
        GradientStop { position: 1.0; color: "#ffeaa7" }  // Light yellow bottom
    }

    property var nightGradient: Gradient {
        GradientStop { position: 0.0; color: "#0f0f23" }  // Very dark blue
        GradientStop { position: 0.5; color: "#1a1a3a" }  // Dark blue
        GradientStop { position: 1.0; color: "#2d2d5a" }  // Slightly lighter bottom
    }

    // Background with gradient
    Rectangle {
        id: gradientBg
        anchors.fill: parent
        radius: parent.radius

        gradient: {
            switch(WeatherService.timeOfDay) {
                case "Day": return root.dayGradient;
                case "Evening": return root.eveningGradient;
                case "Night": return root.nightGradient;
                default: return root.dayGradient;
            }
        }

        Behavior on gradient {
            ColorAnimation { duration: 500 }
        }
    }

    // Sun arc path
    Item {
        id: arcContainer
        anchors.fill: parent
        anchors.margins: 12

        // The arc shape
        Shape {
            id: arcShape
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 40
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 20
            height: width * 0.5

            ShapePath {
                strokeColor: WeatherService.isDay ? 
                    Qt.rgba(1, 1, 1, 0.3) : 
                    Qt.rgba(1, 1, 1, 0.15)
                strokeWidth: 2
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap

                PathArc {
                    x: arcShape.width
                    y: 0
                    radiusX: arcShape.width / 2
                    radiusY: arcShape.height
                    useLargeArc: false
                    direction: PathArc.Counterclockwise
                }
            }
        }

        // Sun/Moon indicator
        Rectangle {
            id: celestialBody
            width: 24
            height: 24
            radius: 12

            // Calculate position on the arc
            property real progress: WeatherService.sunProgress
            property real arcWidth: arcShape.width
            property real arcHeight: arcShape.height
            property real arcCenterX: arcContainer.width / 2
            property real arcCenterY: arcContainer.height - 40

            // Parametric arc position (0 = left, 1 = right)
            property real angle: Math.PI * (1 - progress)  // Goes from PI to 0
            property real posX: arcCenterX + (arcWidth / 2) * Math.cos(angle) - width / 2
            property real posY: arcCenterY - arcHeight * Math.sin(angle) - height / 2

            x: posX
            y: posY

            Behavior on x { NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }
            Behavior on y { NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }

            // Sun appearance
            gradient: WeatherService.isDay ? sunGradient : moonGradient

            property var sunGradient: Gradient {
                GradientStop { position: 0.0; color: "#FFF9C4" }  // Light yellow
                GradientStop { position: 0.5; color: "#FFE082" }  // Yellow
                GradientStop { position: 1.0; color: "#FFB74D" }  // Orange
            }

            property var moonGradient: Gradient {
                GradientStop { position: 0.0; color: "#FFFFFF" }
                GradientStop { position: 0.5; color: "#E8E8E8" }
                GradientStop { position: 1.0; color: "#C0C0C0" }
            }

            // Glow effect
            Rectangle {
                anchors.centerIn: parent
                width: parent.width + 16
                height: parent.height + 16
                radius: width / 2
                color: "transparent"
                border.color: WeatherService.isDay ? 
                    Qt.rgba(1, 0.95, 0.7, 0.4) : 
                    Qt.rgba(1, 1, 1, 0.2)
                border.width: 4
                z: -1
            }

            // Inner glow
            Rectangle {
                anchors.centerIn: parent
                width: parent.width + 8
                height: parent.height + 8
                radius: width / 2
                color: "transparent"
                border.color: WeatherService.isDay ? 
                    Qt.rgba(1, 0.95, 0.7, 0.6) : 
                    Qt.rgba(1, 1, 1, 0.3)
                border.width: 3
                z: -1
            }
        }

        // Horizon line
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 38
            anchors.horizontalCenter: parent.horizontalCenter
            width: arcShape.width + 20
            height: 1
            color: Qt.rgba(1, 1, 1, 0.2)
        }
    }

    // Text content
    ColumnLayout {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 16
        spacing: 2

        // Time of day
        Text {
            text: WeatherService.timeOfDay
            color: WeatherService.timeOfDay === "Night" ? "#FFFFFF" : 
                   WeatherService.timeOfDay === "Evening" ? "#FFFFFF" : "#1a5276"
            font.family: Config.theme.font
            font.pixelSize: Config.theme.fontSize + 6
            font.weight: Font.Bold
        }

        // Weather description
        Text {
            text: WeatherService.weatherDescription
            color: WeatherService.timeOfDay === "Night" ? Qt.rgba(1,1,1,0.7) : 
                   WeatherService.timeOfDay === "Evening" ? Qt.rgba(1,1,1,0.8) : "#2980b9"
            font.family: Config.theme.font
            font.pixelSize: Config.theme.fontSize - 1
            opacity: 0.9
        }
    }

    // Temperature
    Text {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 16
        text: Math.round(WeatherService.currentTemp) + "C°"
        color: WeatherService.timeOfDay === "Night" ? "#FFFFFF" : 
               WeatherService.timeOfDay === "Evening" ? "#FFFFFF" : "#1a5276"
        font.family: Config.theme.font
        font.pixelSize: Config.theme.fontSize + 8
        font.weight: Font.Medium
    }
}
