pragma Singleton

import QtQuick
import qs.config

QtObject {
    // Icon font
    readonly property string font: Config.theme.fillIcons ? "Phosphor-Fill" : "Phosphor-Bold"
    // Overview button icon
    readonly property string overview: ""
    // Powermenu icons
    readonly property string lock: ""
    readonly property string suspend: ""
    readonly property string logout: ""
    readonly property string reboot: ""
    readonly property string shutdown: ""
    // Caret icons
    readonly property string caretLeft: ""
    readonly property string caretRight: ""
    readonly property string caretUp: ""
    readonly property string caretDown: ""
}
