pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell.Widgets
import qs.config
import qs.modules.theme

ClippingRectangle {
    id: root

    clip: true
    antialiasing: true
    contentUnderBorder: true

    required property string variant

    property string gradientOrientation: "vertical"
    property bool enableShadow: false
    property bool enableBorder: true
    property bool animateRadius: true
    property real backgroundOpacity: -1  // -1 means use config value

    readonly property var variantConfig: Styling.getStyledRectConfig(variant)

    readonly property var gradientStops: variantConfig.gradient

    readonly property string gradientType: variantConfig.gradientType

    readonly property real gradientAngle: variantConfig.gradientAngle

    readonly property real gradientCenterX: variantConfig.gradientCenterX

    readonly property real gradientCenterY: variantConfig.gradientCenterY

    readonly property real halftoneDotMin: variantConfig.halftoneDotMin

    readonly property real halftoneDotMax: variantConfig.halftoneDotMax

    readonly property real halftoneStart: variantConfig.halftoneStart

    readonly property real halftoneEnd: variantConfig.halftoneEnd

    readonly property color halftoneDotColor: Config.resolveColor(variantConfig.halftoneDotColor)

    readonly property color halftoneBackgroundColor: Config.resolveColor(variantConfig.halftoneBackgroundColor)

    readonly property var borderData: variantConfig.border

    readonly property color itemColor: Config.resolveColor(variantConfig.itemColor)
    property alias item: root.itemColor

    readonly property real rectOpacity: backgroundOpacity >= 0 ? backgroundOpacity : variantConfig.opacity

    radius: variantConfig.radius !== undefined ? variantConfig.radius : Styling.radius(0)
    color: "transparent"

    Behavior on radius {
        enabled: root.animateRadius && Config.animDuration > 0
        NumberAnimation {
            duration: Config.animDuration / 4
        }
    }

    Behavior on topLeftRadius {
        enabled: root.animateRadius && Config.animDuration > 0
        NumberAnimation {
            duration: Config.animDuration / 4
        }
    }

    Behavior on topRightRadius {
        enabled: root.animateRadius && Config.animDuration > 0
        NumberAnimation {
            duration: Config.animDuration / 4
        }
    }

    Behavior on bottomLeftRadius {
        enabled: root.animateRadius && Config.animDuration > 0
        NumberAnimation {
            duration: Config.animDuration / 4
        }
    }

    Behavior on bottomRightRadius {
        enabled: root.animateRadius && Config.animDuration > 0
        NumberAnimation {
            duration: Config.animDuration / 4
        }
    }

    // Linear gradient
    Rectangle {
        id: linearGrad
        opacity: rectOpacity
        readonly property real maxDim: Math.max(parent.width, parent.height)
        readonly property real angleRad: gradientAngle * Math.PI / 180
        readonly property real cosAbs: Math.abs(Math.cos(angleRad))
        readonly property real sinAbs: Math.abs(Math.sin(angleRad))
        readonly property real scaleX: (parent.width * cosAbs + parent.height * sinAbs) / maxDim
        readonly property real scaleY: (parent.height * cosAbs + parent.width * sinAbs) / maxDim

        antialiasing: true

        width: maxDim
        height: maxDim
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        visible: gradientType === "linear"
        rotation: gradientAngle
        transformOrigin: Item.Center

        transform: Scale {
            xScale: linearGrad.scaleX
            yScale: linearGrad.scaleY
            origin.x: linearGrad.width / 2
            origin.y: linearGrad.height / 2
        }

        gradient: Gradient {
            orientation: gradientOrientation === "horizontal" ? Gradient.Horizontal : Gradient.Vertical

            GradientStop {
                property var stopData: gradientStops[0] || ["surface", 0.0]
                position: stopData[1]
                color: Config.resolveColor(stopData[0])
            }

            GradientStop {
                property var stopData: gradientStops[1] || gradientStops[gradientStops.length - 1]
                position: stopData[1]
                color: Config.resolveColor(stopData[0])
            }

            GradientStop {
                property var stopData: gradientStops[2] || gradientStops[gradientStops.length - 1]
                position: stopData[1]
                color: Config.resolveColor(stopData[0])
            }

            GradientStop {
                property var stopData: gradientStops[3] || gradientStops[gradientStops.length - 1]
                position: stopData[1]
                color: Config.resolveColor(stopData[0])
            }

            GradientStop {
                property var stopData: gradientStops[4] || gradientStops[gradientStops.length - 1]
                position: stopData[1]
                color: Config.resolveColor(stopData[0])
            }

            GradientStop {
                property var stopData: gradientStops[5] || gradientStops[gradientStops.length - 1]
                position: stopData[1]
                color: Config.resolveColor(stopData[0])
            }

            GradientStop {
                property var stopData: gradientStops[6] || gradientStops[gradientStops.length - 1]
                position: stopData[1]
                color: Config.resolveColor(stopData[0])
            }

            GradientStop {
                property var stopData: gradientStops[7] || gradientStops[gradientStops.length - 1]
                position: stopData[1]
                color: Config.resolveColor(stopData[0])
            }

            GradientStop {
                property var stopData: gradientStops[8] || gradientStops[gradientStops.length - 1]
                position: stopData[1]
                color: Config.resolveColor(stopData[0])
            }

            GradientStop {
                property var stopData: gradientStops[9] || gradientStops[gradientStops.length - 1]
                position: stopData[1]
                color: Config.resolveColor(stopData[0])
            }

            GradientStop {
                property var stopData: gradientStops[10] || gradientStops[gradientStops.length - 1]
                position: stopData[1]
                color: Config.resolveColor(stopData[0])
            }

            GradientStop {
                property var stopData: gradientStops[11] || gradientStops[gradientStops.length - 1]
                position: stopData[1]
                color: Config.resolveColor(stopData[0])
            }

            GradientStop {
                property var stopData: gradientStops[12] || gradientStops[gradientStops.length - 1]
                position: stopData[1]
                color: Config.resolveColor(stopData[0])
            }

            GradientStop {
                property var stopData: gradientStops[13] || gradientStops[gradientStops.length - 1]
                position: stopData[1]
                color: Config.resolveColor(stopData[0])
            }

            GradientStop {
                property var stopData: gradientStops[14] || gradientStops[gradientStops.length - 1]
                position: stopData[1]
                color: Config.resolveColor(stopData[0])
            }

            GradientStop {
                property var stopData: gradientStops[15] || gradientStops[gradientStops.length - 1]
                position: stopData[1]
                color: Config.resolveColor(stopData[0])
            }

            GradientStop {
                property var stopData: gradientStops[16] || gradientStops[gradientStops.length - 1]
                position: stopData[1]
                color: Config.resolveColor(stopData[0])
            }

            GradientStop {
                property var stopData: gradientStops[17] || gradientStops[gradientStops.length - 1]
                position: stopData[1]
                color: Config.resolveColor(stopData[0])
            }

            GradientStop {
                property var stopData: gradientStops[18] || gradientStops[gradientStops.length - 1]
                position: stopData[1]
                color: Config.resolveColor(stopData[0])
            }

            GradientStop {
                property var stopData: gradientStops[19] || gradientStops[gradientStops.length - 1]
                position: stopData[1]
                color: Config.resolveColor(stopData[0])
            }
        }
    }

    // Radial gradient
    Shape {
        id: radialShape
        opacity: rectOpacity
        readonly property real maxDim: Math.max(parent.width, parent.height)
        width: maxDim + 2
        height: maxDim + 2
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        visible: gradientType === "radial"
        layer.enabled: true
        layer.smooth: true

        transform: Scale {
            xScale: radialShape.parent.width / radialShape.maxDim
            yScale: radialShape.parent.height / radialShape.maxDim
            origin.x: radialShape.width / 2
            origin.y: radialShape.height / 2
        }

        ShapePath {
            fillGradient: RadialGradient {
                centerX: radialShape.width * gradientCenterX
                centerY: radialShape.height * gradientCenterY
                centerRadius: radialShape.maxDim
                focalX: centerX
                focalY: centerY

                GradientStop {
                    property var stopData: gradientStops[0] || ["surface", 0.0]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: gradientStops[1] || gradientStops[gradientStops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: gradientStops[2] || gradientStops[gradientStops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: gradientStops[3] || gradientStops[gradientStops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: gradientStops[4] || gradientStops[gradientStops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: gradientStops[5] || gradientStops[gradientStops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: gradientStops[6] || gradientStops[gradientStops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: gradientStops[7] || gradientStops[gradientStops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: gradientStops[8] || gradientStops[gradientStops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: gradientStops[9] || gradientStops[gradientStops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: gradientStops[10] || gradientStops[gradientStops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: gradientStops[11] || gradientStops[gradientStops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: gradientStops[12] || gradientStops[gradientStops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: gradientStops[13] || gradientStops[gradientStops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: gradientStops[14] || gradientStops[gradientStops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: gradientStops[15] || gradientStops[gradientStops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: gradientStops[16] || gradientStops[gradientStops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: gradientStops[17] || gradientStops[gradientStops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: gradientStops[18] || gradientStops[gradientStops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }

                GradientStop {
                    property var stopData: gradientStops[19] || gradientStops[gradientStops.length - 1]
                    position: stopData[1]
                    color: Config.resolveColor(stopData[0])
                }
            }

            startX: 0
            startY: 0

            PathLine {
                x: radialShape.width
                y: 0
            }
            PathLine {
                x: radialShape.width
                y: radialShape.height
            }
            PathLine {
                x: 0
                y: radialShape.height
            }
            PathLine {
                x: 0
                y: 0
            }
        }
    }

    // Halftone gradient
    ShaderEffect {
        anchors.fill: parent
        opacity: rectOpacity
        visible: gradientType === "halftone"

        property real angle: gradientAngle
        property real dotMinSize: halftoneDotMin
        property real dotMaxSize: halftoneDotMax
        property real gradientStart: halftoneStart
        property real gradientEnd: halftoneEnd
        property vector4d dotColor: {
            const c = halftoneDotColor || Qt.rgba(1, 1, 1, 1);
            return Qt.vector4d(c.r, c.g, c.b, c.a);
        }
        property vector4d backgroundColor: {
            const c = halftoneBackgroundColor || Qt.rgba(0, 0.5, 1, 1);
            return Qt.vector4d(c.r, c.g, c.b, c.a);
        }
        property real canvasWidth: width
        property real canvasHeight: height

        vertexShader: "halftone.vert.qsb"
        fragmentShader: "halftone.frag.qsb"
    }

    // Shadow effect
    layer.enabled: enableShadow
    layer.effect: Shadow {}

    // Border overlay to avoid ClippingRectangle artifacts
    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: "transparent"
        border.color: Config.resolveColor(borderData[0])
        border.width: borderData[1]
        visible: root.enableBorder
    }
}
