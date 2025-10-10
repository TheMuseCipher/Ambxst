import QtQuick
import QtQuick.Effects
import qs.modules.theme
import qs.config

Rectangle {
    radius: Config.roundness
    border.color: Colors.surfaceBright
    border.width: 0

    gradient: Gradient {
        orientation: Config.theme.paneOrientation === "horizontal" ? Gradient.Horizontal : Gradient.Vertical
        
        GradientStop {
            property var stopData: Config.theme.paneColor[0] || ["surface", 0.0]
            position: stopData[1]
            color: {
                const colorValue = stopData[0];
                if (colorValue.startsWith("#") || colorValue.startsWith("rgba") || colorValue.startsWith("rgb")) {
                    return colorValue;
                }
                return Colors[colorValue] || colorValue;
            }
        }
        
        GradientStop {
            property var stopData: Config.theme.paneColor[1] || Config.theme.paneColor[Config.theme.paneColor.length - 1]
            position: stopData[1]
            color: {
                const colorValue = stopData[0];
                if (colorValue.startsWith("#") || colorValue.startsWith("rgba") || colorValue.startsWith("rgb")) {
                    return colorValue;
                }
                return Colors[colorValue] || colorValue;
            }
        }
        
        GradientStop {
            property var stopData: Config.theme.paneColor[2] || Config.theme.paneColor[Config.theme.paneColor.length - 1]
            position: stopData[1]
            color: {
                const colorValue = stopData[0];
                if (colorValue.startsWith("#") || colorValue.startsWith("rgba") || colorValue.startsWith("rgb")) {
                    return colorValue;
                }
                return Colors[colorValue] || colorValue;
            }
        }
        
        GradientStop {
            property var stopData: Config.theme.paneColor[3] || Config.theme.paneColor[Config.theme.paneColor.length - 1]
            position: stopData[1]
            color: {
                const colorValue = stopData[0];
                if (colorValue.startsWith("#") || colorValue.startsWith("rgba") || colorValue.startsWith("rgb")) {
                    return colorValue;
                }
                return Colors[colorValue] || colorValue;
            }
        }
        
        GradientStop {
            property var stopData: Config.theme.paneColor[4] || Config.theme.paneColor[Config.theme.paneColor.length - 1]
            position: stopData[1]
            color: {
                const colorValue = stopData[0];
                if (colorValue.startsWith("#") || colorValue.startsWith("rgba") || colorValue.startsWith("rgb")) {
                    return colorValue;
                }
                return Colors[colorValue] || colorValue;
            }
        }
    }

    layer.enabled: false
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowHorizontalOffset: 0
        shadowVerticalOffset: 0
        shadowBlur: 1
         shadowColor: Colors[Config.theme.shadowColor] || Colors.shadow
        shadowOpacity: Config.theme.shadowOpacity
    }
}
