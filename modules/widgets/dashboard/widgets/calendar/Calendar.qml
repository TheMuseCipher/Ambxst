import QtQuick
import QtQuick.Layouts
import qs.modules.theme
import qs.modules.components
import qs.config
import "layout.js" as CalendarLayout

PaneRect {
    id: root

    property int monthShift: 0
    property var viewingDate: CalendarLayout.getDateInXMonthsTime(monthShift)
    property var calendarLayoutData: CalendarLayout.getCalendarLayout(viewingDate, monthShift === 0)
    property var calendarLayout: calendarLayoutData.calendar
    property int currentWeekRow: calendarLayoutData.currentWeekRow
    property int currentDayOfWeek: {
        if (monthShift !== 0)
            return -1;
        var now = new Date();
        return (now.getDay() + 6) % 7;
    }
    property var weekDays: [
        {
            day: 'Mo',
            today: 0
        },
        {
            day: 'Tu',
            today: 0
        },
        {
            day: 'We',
            today: 0
        },
        {
            day: 'Th',
            today: 0
        },
        {
            day: 'Fr',
            today: 0
        },
        {
            day: 'Sa',
            today: 0
        },
        {
            day: 'Su',
            today: 0
        }
    ]

    ColumnLayout {
        id: calendarColumn
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            // Layout.leftMargin: 8
            // Layout.rightMargin: 8
            spacing: 4

            Rectangle {
                Layout.preferredWidth: 150
                Layout.preferredHeight: 32
                color: Colors.background
                radius: Config.roundness > 0 ? Config.roundness - 4 : 0
                Text {
                    Layout.fillWidth: true
                    anchors.centerIn: parent
                    text: viewingDate.toLocaleDateString(Qt.locale(), "MMMM yyyy")
                    font.pixelSize: Config.theme.fontSize
                    font.weight: Font.Bold
                    font.family: Config.defaultFont
                    color: Colors.overSurface
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Rectangle {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                color: leftMouseArea.containsMouse ? Colors.surfaceBright : Colors.background
                radius: Config.roundness > 0 ? Config.roundness - 4 : 0

                Behavior on color {
                    ColorAnimation {
                        duration: Config.animDuration / 2
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: Icons.caretLeft
                    font.pixelSize: 16
                    color: Colors.overSurface
                }

                MouseArea {
                    id: leftMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: monthShift--
                    cursorShape: Qt.PointingHandCursor
                }
            }

            Rectangle {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                color: rightMouseArea.containsMouse ? Colors.surfaceBright : Colors.background
                radius: Config.roundness > 0 ? Config.roundness - 4 : 0

                Behavior on color {
                    ColorAnimation {
                        duration: Config.animDuration / 2
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: Icons.caretRight
                    font.pixelSize: 16
                    color: Colors.overSurface
                }

                MouseArea {
                    id: rightMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: monthShift++
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Colors.background
            radius: Config.roundness > 0 ? Config.roundness - 4 : 0

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 0

                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter

                    Repeater {
                        model: weekDays
                        delegate: CalendarDayButton {
                            required property int index
                            day: root.weekDays[index].day
                            isToday: root.weekDays[index].today
                            bold: true
                            isCurrentDayOfWeek: index === root.currentDayOfWeek
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    Layout.preferredHeight: 2
                    color: Colors.surface
                }

                Repeater {
                    model: 6
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredHeight: 32
                        color: (rowIndex === root.currentWeekRow) ? Colors.surface : "transparent"
                        radius: Config.roundness > 0 ? Config.roundness - 4 : 0

                        required property int index
                        property int rowIndex: index

                        RowLayout {
                            anchors.fill: parent
                            spacing: 0

                            Repeater {
                                model: 7
                                delegate: CalendarDayButton {
                                    required property int index
                                    day: calendarLayout[rowIndex][index].day
                                    isToday: calendarLayout[rowIndex][index].today
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
