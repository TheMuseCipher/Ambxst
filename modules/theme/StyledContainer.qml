import QtQuick
import QtQuick.Effects
import qs.modules.theme
import qs.config

Rectangle {
    color: Colors.background
    radius: Configuration.roundness
    border.color: Colors.adapter.surfaceBright
    border.width: 0

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowHorizontalOffset: 0
        shadowVerticalOffset: 0
        shadowBlur: 0.5
        shadowColor: Qt.rgba(Colors.adapter.shadow.r, Colors.adapter.shadow.g, Colors.adapter.shadow.b, 0.5)
    }
}
