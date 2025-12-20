pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.modules.theme
import qs.modules.components
import qs.modules.services

Item {
    id: root

    property string currentTime: ""
    property string currentDayAbbrev: ""
    property string currentHours: ""
    property string currentMinutes: ""
    property string currentFullDate: ""

    required property var bar
    property bool vertical: bar.orientation === "vertical"
    property bool isHovered: false
    property bool layerEnabled: true

    // Popup visibility state
    property bool popupOpen: clockPopup.isOpen

    // Weather availability
    readonly property bool weatherAvailable: WeatherService.dataAvailable

    Layout.preferredWidth: vertical ? 36 : buttonBg.implicitWidth
    Layout.preferredHeight: vertical ? buttonBg.implicitHeight : 36

    HoverHandler {
        onHoveredChanged: root.isHovered = hovered
    }

    // Main button
    StyledRect {
        id: buttonBg
        variant: root.popupOpen ? "primary" : "bg"
        anchors.fill: parent
        enableShadow: root.layerEnabled

        implicitWidth: vertical ? 36 : rowLayout.implicitWidth + 24
        implicitHeight: vertical ? columnLayout.implicitHeight + 24 : 36

        Rectangle {
            anchors.fill: parent
            color: Colors.primary
            opacity: root.popupOpen ? 0 : (root.isHovered ? 0.25 : 0)
            radius: parent.radius ?? 0

            Behavior on opacity {
                enabled: Config.animDuration > 0
                NumberAnimation {
                    duration: Config.animDuration / 2
                }
            }
        }

        RowLayout {
            id: rowLayout
            visible: !root.vertical
            anchors.centerIn: parent
            spacing: 8

            Text {
                id: dayDisplay
                text: root.weatherAvailable ? WeatherService.weatherSymbol : root.currentDayAbbrev
                color: root.popupOpen ? buttonBg.itemColor : Colors.overBackground
                font.pixelSize: root.weatherAvailable ? 16 : Config.theme.fontSize
                font.family: root.weatherAvailable ? Config.theme.font : Config.theme.font
                font.bold: !root.weatherAvailable
            }

            Separator {
                id: separator
                vert: true
            }

            Text {
                id: timeDisplay
                text: root.currentTime
                color: root.popupOpen ? buttonBg.itemColor : Colors.overBackground
                font.pixelSize: Config.theme.fontSize
                font.family: Config.theme.font
                font.bold: true
            }
        }

        ColumnLayout {
            id: columnLayout
            visible: root.vertical
            anchors.centerIn: parent
            spacing: 4
            Layout.alignment: Qt.AlignHCenter

            Text {
                id: dayDisplayV
                text: root.weatherAvailable ? WeatherService.weatherSymbol : root.currentDayAbbrev
                color: root.popupOpen ? buttonBg.itemColor : Colors.overBackground
                font.pixelSize: root.weatherAvailable ? 16 : Config.theme.fontSize
                font.family: Config.theme.font
                font.bold: !root.weatherAvailable
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.NoWrap
                Layout.alignment: Qt.AlignHCenter
            }

            Separator {
                id: separatorV
                vert: false
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                id: hoursDisplayV
                text: root.currentHours
                color: root.popupOpen ? buttonBg.itemColor : Colors.overBackground
                font.pixelSize: Config.theme.fontSize
                font.family: Config.theme.font
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.NoWrap
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                id: minutesDisplayV
                text: root.currentMinutes
                color: root.popupOpen ? buttonBg.itemColor : Colors.overBackground
                font.pixelSize: Config.theme.fontSize
                font.family: Config.theme.font
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.NoWrap
                Layout.alignment: Qt.AlignHCenter
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: false
            cursorShape: Qt.PointingHandCursor
            onClicked: clockPopup.toggle()
        }
    }

    // Clock & Weather popup
    BarPopup {
        id: clockPopup
        anchorItem: buttonBg
        bar: root.bar
        visualMargin: 8
        popupPadding: 0

        contentWidth: 260
        contentHeight: 140

        // Weather widget with sun arc
        Item {
            id: popupContent
            anchors.fill: parent
            anchors.margins: Config.theme.srPopup.border[1]
            visible: root.weatherAvailable

            // Weather card with gradient background
            Rectangle {
                id: weatherCard
                anchors.fill: parent
                radius: Styling.radius(4 - Config.theme.srPopup.border[1])
                clip: true

                // Dynamic gradient based on time of day
                gradient: Gradient {
                    GradientStop { 
                        position: 0.0
                        color: WeatherService.timeOfDay === "Night" ? "#0f0f23" :
                               WeatherService.timeOfDay === "Evening" ? "#1a1a2e" : "#87CEEB"
                    }
                    GradientStop { 
                        position: 0.5
                        color: WeatherService.timeOfDay === "Night" ? "#1a1a3a" :
                               WeatherService.timeOfDay === "Evening" ? "#e94560" : "#B0E0E6"
                    }
                    GradientStop { 
                        position: 1.0
                        color: WeatherService.timeOfDay === "Night" ? "#2d2d5a" :
                               WeatherService.timeOfDay === "Evening" ? "#ffeaa7" : "#E0F6FF"
                    }
                }

                // Sun arc container
                Item {
                    id: arcContainer
                    anchors.fill: parent

                    // Arc dimensions - elliptical arc that fits within the container
                    property real arcWidth: width - 40  // Horizontal span
                    property real arcHeight: 70  // Vertical height of the arc
                    property real arcCenterX: width / 2
                    property real arcCenterY: height - 12  // Position at bottom edge

                    // The arc path (upper half of ellipse only)
                    Canvas {
                        id: arcCanvas
                        anchors.fill: parent

                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();
                            ctx.strokeStyle = WeatherService.isDay ? 
                                "rgba(255, 255, 255, 0.3)" : "rgba(255, 255, 255, 0.15)";
                            ctx.lineWidth = 1.5;
                            
                            var cx = arcContainer.arcCenterX;
                            var cy = arcContainer.arcCenterY;
                            var rx = arcContainer.arcWidth / 2;
                            var ry = arcContainer.arcHeight;
                            
                            // Draw only the upper half of the ellipse manually
                            ctx.beginPath();
                            ctx.moveTo(cx - rx, cy);
                            
                            // Use quadratic bezier curves to approximate upper ellipse arc
                            var steps = 50;
                            for (var i = 0; i <= steps; i++) {
                                var angle = Math.PI - (Math.PI * i / steps);  // PI to 0
                                var x = cx + rx * Math.cos(angle);
                                var y = cy - ry * Math.sin(angle);  // Subtract to go up
                                ctx.lineTo(x, y);
                            }
                            
                            ctx.stroke();
                        }

                        Component.onCompleted: requestPaint()
                        
                        Connections {
                            target: WeatherService
                            function onIsDayChanged() { arcCanvas.requestPaint() }
                        }
                        
                        onWidthChanged: requestPaint()
                        onHeightChanged: requestPaint()
                    }

                    // Horizon line
                    Rectangle {
                        x: arcContainer.arcCenterX - arcContainer.arcWidth / 2 - 8
                        y: arcContainer.arcCenterY
                        width: arcContainer.arcWidth + 16
                        height: 1
                        color: Qt.rgba(1, 1, 1, 0.2)
                    }

                    // Sun/Moon indicator
                    Rectangle {
                        id: celestialBody
                        width: 20
                        height: 20
                        radius: 10

                        property real progress: WeatherService.sunProgress
                        
                        // Elliptical arc position calculation
                        property real angle: Math.PI * (1 - progress)  // PI to 0
                        property real posX: arcContainer.arcCenterX + (arcContainer.arcWidth / 2) * Math.cos(angle) - width / 2
                        property real posY: arcContainer.arcCenterY - arcContainer.arcHeight * Math.sin(angle) - height / 2

                        x: posX
                        y: posY

                        Behavior on x { NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }
                        Behavior on y { NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }

                        gradient: Gradient {
                            GradientStop { 
                                position: 0.0
                                color: WeatherService.isDay ? "#FFF9C4" : "#FFFFFF"
                            }
                            GradientStop { 
                                position: 0.5
                                color: WeatherService.isDay ? "#FFE082" : "#E8E8E8"
                            }
                            GradientStop { 
                                position: 1.0
                                color: WeatherService.isDay ? "#FFB74D" : "#C0C0C0"
                            }
                        }

                        // Outer glow
                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width + 12
                            height: parent.height + 12
                            radius: width / 2
                            color: "transparent"
                            border.color: WeatherService.isDay ? 
                                Qt.rgba(1, 0.95, 0.7, 0.4) : Qt.rgba(1, 1, 1, 0.2)
                            border.width: 3
                            z: -1
                        }

                        // Inner glow
                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width + 6
                            height: parent.height + 6
                            radius: width / 2
                            color: "transparent"
                            border.color: WeatherService.isDay ? 
                                Qt.rgba(1, 0.95, 0.7, 0.6) : Qt.rgba(1, 1, 1, 0.3)
                            border.width: 2
                            z: -1
                        }
                    }
                }

                // Time of day label (top left)
                Column {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.margins: 12
                    spacing: 2

                    Text {
                        text: WeatherService.timeOfDay
                        color: WeatherService.timeOfDay === "Day" ? "#1a5276" : "#FFFFFF"
                        font.family: Config.theme.font
                        font.pixelSize: Config.theme.fontSize + 4
                        font.weight: Font.Bold
                    }

                    Text {
                        text: WeatherService.weatherDescription
                        color: WeatherService.timeOfDay === "Day" ? "#2980b9" : 
                               Qt.rgba(1, 1, 1, 0.7)
                        font.family: Config.theme.font
                        font.pixelSize: Config.theme.fontSize - 2
                    }
                }

                // Temperature (top right)
                Text {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 12
                    text: Math.round(WeatherService.currentTemp) + Config.weather.unit + "°"
                    color: WeatherService.timeOfDay === "Day" ? "#1a5276" : "#FFFFFF"
                    font.family: Config.theme.font
                    font.pixelSize: Config.theme.fontSize + 6
                    font.weight: Font.Medium
                }
            }
        }
    }

    function scheduleNextDayUpdate() {
        var now = new Date();
        var next = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1, 0, 0, 1);
        var ms = next - now;
        dayUpdateTimer.interval = ms;
        dayUpdateTimer.start();
    }

    function updateDay() {
        var now = new Date();
        var day = Qt.formatDateTime(now, Qt.locale(), "ddd");
        root.currentDayAbbrev = day.slice(0, 3).charAt(0).toUpperCase() + day.slice(1, 3);
        root.currentFullDate = Qt.formatDateTime(now, Qt.locale(), "dddd, MMMM d, yyyy");
        scheduleNextDayUpdate();
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var now = new Date();
            var formatted = Qt.formatDateTime(now, "hh:mm");
            var parts = formatted.split(":");
            root.currentTime = formatted;
            root.currentHours = parts[0];
            root.currentMinutes = parts[1];
        }
    }

    Timer {
        id: dayUpdateTimer
        repeat: false
        running: false
        onTriggered: updateDay()
    }

    Component.onCompleted: {
        var now = new Date();
        var formatted = Qt.formatDateTime(now, "hh:mm");
        var parts = formatted.split(":");
        root.currentTime = formatted;
        root.currentHours = parts[0];
        root.currentMinutes = parts[1];
        updateDay();
    }
}
