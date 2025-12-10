pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.theme
import qs.modules.components
import qs.modules.globals
import qs.config

Item {
    id: root

    property int maxContentWidth: 480
    readonly property int contentWidth: Math.min(width, maxContentWidth)
    readonly property real sideMargin: (width - contentWidth) / 2

    property string selectedVariant: "bg"

    readonly property var allVariants: [
        {
            id: "bg",
            label: "Background"
        },
        {
            id: "internalbg",
            label: "Internal BG"
        },
        {
            id: "barbg",
            label: "Bar BG"
        },
        {
            id: "pane",
            label: "Pane"
        },
        {
            id: "common",
            label: "Common"
        },
        {
            id: "focus",
            label: "Focus"
        },
        {
            id: "primary",
            label: "Primary"
        },
        {
            id: "primaryfocus",
            label: "Primary Focus"
        },
        {
            id: "overprimary",
            label: "Over Primary"
        },
        {
            id: "secondary",
            label: "Secondary"
        },
        {
            id: "secondaryfocus",
            label: "Secondary Focus"
        },
        {
            id: "oversecondary",
            label: "Over Secondary"
        },
        {
            id: "tertiary",
            label: "Tertiary"
        },
        {
            id: "tertiaryfocus",
            label: "Tertiary Focus"
        },
        {
            id: "overtertiary",
            label: "Over Tertiary"
        },
        {
            id: "error",
            label: "Error"
        },
        {
            id: "errorfocus",
            label: "Error Focus"
        },
        {
            id: "overerror",
            label: "Over Error"
        }
    ]

    function getVariantLabel(variantId: string): string {
        for (var i = 0; i < allVariants.length; i++) {
            if (allVariants[i].id === variantId) {
                return allVariants[i].label;
            }
        }
        return variantId;
    }

    // Main content - single Flickable for everything, fills entire width
    Flickable {
        id: mainFlickable
        anchors.fill: parent
        contentHeight: mainColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        interactive: true

        ColumnLayout {
            id: mainColumn
            width: mainFlickable.width
            spacing: 8

            // Header wrapper
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: titlebar.height

                PanelTitlebar {
                    id: titlebar
                    width: root.contentWidth
                    anchors.horizontalCenter: parent.horizontalCenter
                    title: "Theme"
                    statusText: GlobalStates.themeHasChanges ? "Unsaved changes" : ""
                    statusColor: Colors.error

                    actions: [
                        {
                            icon: Icons.arrowCounterClockwise,
                            tooltip: "Discard changes",
                            enabled: GlobalStates.themeHasChanges,
                            onClicked: function () {
                                GlobalStates.discardThemeChanges();
                            }
                        },
                        {
                            icon: Icons.disk,
                            tooltip: "Apply changes",
                            enabled: GlobalStates.themeHasChanges,
                            onClicked: function () {
                                GlobalStates.applyThemeChanges();
                            }
                        }
                    ]
                }
            }

            // Content wrapper - centered
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: contentColumn.implicitHeight

                ColumnLayout {
                    id: contentColumn
                    width: root.contentWidth
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 12

                    // Variant selector section
                    StyledRect {
                        variant: "pane"
                        Layout.fillWidth: true
                        Layout.preferredHeight: variantSelectorContent.implicitHeight + 24
                        radius: Styling.radius(-2)

                        ColumnLayout {
                            id: variantSelectorContent
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8

                            Text {
                                text: "Variant"
                                font.family: Config.theme.font
                                font.pixelSize: Styling.fontSize(-1)
                                font.weight: Font.Medium
                                color: Colors.overSurfaceVariant
                            }

                            Flow {
                                id: variantsFlow
                                Layout.fillWidth: true
                                spacing: 4

                                Repeater {
                                    model: root.allVariants

                                    delegate: StyledRect {
                                        id: variantTag
                                        required property var modelData
                                        required property int index

                                        property bool isSelected: root.selectedVariant === modelData.id
                                        property bool isHovered: false

                                        variant: modelData.id

                                        width: tagContent.width + 24 + (isSelected ? checkIcon.width + 4 : 0)
                                        height: 32
                                        radius: isSelected ? Styling.radius(0) / 2 : Styling.radius(0)

                                        Behavior on width {
                                            enabled: (Config.animDuration ?? 0) > 0
                                            NumberAnimation {
                                                duration: (Config.animDuration ?? 0) / 3
                                                easing.type: Easing.OutCubic
                                            }
                                        }

                                        Item {
                                            anchors.fill: parent
                                            anchors.margins: 8

                                            Row {
                                                anchors.centerIn: parent
                                                spacing: variantTag.isSelected ? 4 : 0

                                                Item {
                                                    width: checkIcon.visible ? checkIcon.width : 0
                                                    height: checkIcon.height
                                                    clip: true

                                                    Text {
                                                        id: checkIcon
                                                        text: Icons.accept
                                                        font.family: Icons.font
                                                        font.pixelSize: 16
                                                        color: variantTag.itemColor
                                                        visible: variantTag.isSelected
                                                        opacity: variantTag.isSelected ? 1 : 0

                                                        Behavior on opacity {
                                                            enabled: (Config.animDuration ?? 0) > 0
                                                            NumberAnimation {
                                                                duration: (Config.animDuration ?? 0) / 3
                                                                easing.type: Easing.OutCubic
                                                            }
                                                        }
                                                    }

                                                    Behavior on width {
                                                        enabled: (Config.animDuration ?? 0) > 0
                                                        NumberAnimation {
                                                            duration: (Config.animDuration ?? 0) / 3
                                                            easing.type: Easing.OutCubic
                                                        }
                                                    }
                                                }

                                                Text {
                                                    id: tagContent
                                                    text: variantTag.modelData.label
                                                    font.family: Config.theme.font
                                                    font.pixelSize: Config.theme.fontSize
                                                    font.bold: true
                                                    color: variantTag.itemColor

                                                    Behavior on color {
                                                        enabled: (Config.animDuration ?? 0) > 0
                                                        ColorAnimation {
                                                            duration: (Config.animDuration ?? 0) / 3
                                                            easing.type: Easing.OutCubic
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        Rectangle {
                                            id: hoverOverlay
                                            anchors.fill: parent
                                            color: Colors.primary
                                            radius: variantTag.radius ?? 0
                                            opacity: variantTag.isHovered ? 0.15 : 0

                                            Behavior on opacity {
                                                enabled: (Config.animDuration ?? 0) > 0
                                                NumberAnimation {
                                                    duration: (Config.animDuration ?? 0) / 2
                                                }
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor

                                            onEntered: variantTag.isHovered = true
                                            onExited: variantTag.isHovered = false

                                            onClicked: root.selectedVariant = variantTag.modelData.id
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Roundness section
                    StyledRect {
                        variant: "pane"
                        Layout.fillWidth: true
                        Layout.preferredHeight: roundnessContent.implicitHeight + 24
                        radius: Styling.radius(-2)

                        RowLayout {
                            id: roundnessContent
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Text {
                                text: "Roundness"
                                font.family: Config.theme.font
                                font.pixelSize: Styling.fontSize(0)
                                font.weight: Font.Medium
                                color: Colors.overBackground
                            }

                            StyledSlider {
                                id: roundnessSlider
                                Layout.fillWidth: true
                                Layout.preferredHeight: 20
                                progressColor: Colors.primary
                                tooltipText: `${Math.round(value * 20)}`
                                scroll: true

                                // Use a computed property that always reads from Config
                                readonly property real configValue: Config.theme.roundness / 20

                                // Sync value when configValue changes (e.g., after discard)
                                onConfigValueChanged: {
                                    if (Math.abs(value - configValue) > 0.001) {
                                        value = configValue;
                                    }
                                }

                                Component.onCompleted: value = configValue

                                onValueChanged: {
                                    if (Math.round(value * 20) !== Config.theme.roundness) {
                                        GlobalStates.markThemeChanged();
                                        Config.theme.roundness = Math.round(value * 20);
                                    }
                                }
                            }

                            Text {
                                text: Math.round(roundnessSlider.value * 20)
                                font.family: Config.theme.font
                                font.pixelSize: Styling.fontSize(0)
                                color: Colors.overBackground
                                horizontalAlignment: Text.AlignRight
                                Layout.preferredWidth: 24
                            }
                        }
                    }

                    // Editor section
                    StyledRect {
                        variant: "pane"
                        Layout.fillWidth: true
                        Layout.preferredHeight: editorContent.implicitHeight + 24
                        radius: Styling.radius(-2)

                        ColumnLayout {
                            id: editorContent
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8

                            Text {
                                text: "Editor - " + root.getVariantLabel(root.selectedVariant)
                                font.family: Config.theme.font
                                font.pixelSize: Styling.fontSize(-1)
                                font.weight: Font.Medium
                                color: Colors.overSurfaceVariant
                            }

                            VariantEditor {
                                Layout.fillWidth: true
                                variantId: root.selectedVariant
                                onClose: {}
                            }
                        }
                    }
                }
            }
        }
    }
}
