import QtQuick
import qs.config
import qs.modules.theme

Rectangle {
    property bool vert: false

    radius: Styling.radius(0)

    gradient: Gradient {
        orientation: vert ? Gradient.Horizontal : Gradient.Vertical
        
        GradientStop {
            property var stopData: Config.theme.separatorColor[0] || ["surfaceBright", 0.0]
            position: stopData[1]
            color: Config.resolveColor(stopData[0])
        }

        GradientStop {
            property var stopData: Config.theme.separatorColor[1] || Config.theme.separatorColor[Config.theme.separatorColor.length - 1]
            position: stopData[1]
            color: Config.resolveColor(stopData[0])
        }

        GradientStop {
            property var stopData: Config.theme.separatorColor[2] || Config.theme.separatorColor[Config.theme.separatorColor.length - 1]
            position: stopData[1]
            color: Config.resolveColor(stopData[0])
        }

        GradientStop {
            property var stopData: Config.theme.separatorColor[3] || Config.theme.separatorColor[Config.theme.separatorColor.length - 1]
            position: stopData[1]
            color: Config.resolveColor(stopData[0])
        }

        GradientStop {
            property var stopData: Config.theme.separatorColor[4] || Config.theme.separatorColor[Config.theme.separatorColor.length - 1]
            position: stopData[1]
            color: Config.resolveColor(stopData[0])
        }
    }

    width: vert ? 20 : 2
    height: vert ? 2 : 20
}
