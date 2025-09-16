import QtQuick
import Quickshell
import Quickshell.Io
import qs.config
import qs.modules.theme

QtObject {
    id: root

    property Process hyprctlProcess: Process {}

    function getColorValue(colorName) {
        return Colors.adapter[colorName] || Colors.adapter.primary;
    }

    function formatColorForHyprland(color) {
        // Hyprland expects colors in format: rgb(rrggbb) or rgba(rrggbbaa)
        const r = Math.round(color.r * 255).toString(16).padStart(2, '0');
        const g = Math.round(color.g * 255).toString(16).padStart(2, '0');
        const b = Math.round(color.b * 255).toString(16).padStart(2, '0');
        const a = Math.round(color.a * 255).toString(16).padStart(2, '0');

        if (color.a === 1.0) {
            return `rgb(${r}${g}${b})`;
        } else {
            return `rgba(${r}${g}${b}${a})`;
        }
    }

    function applyHyprlandConfig() {
        // Verificar que los adapters estén cargados antes de aplicar configuración
        if (!Config.loader.loaded || !Colors.loaded) {
            console.log("HyprlandConfig: Esperando que se carguen los adapters...");
            return;
        }

        const activeColor = getColorValue(Config.theme.currentTheme === "sticker" ? "overBackground" : Config.hyprlandBorderColor);
        const inactiveColor = getColorValue(Config.hyprland.inactiveBorderColor);

        // Para el color inactivo, usar con opacidad completa como especificaste
        const inactiveColorWithFullOpacity = Qt.rgba(inactiveColor.r, inactiveColor.g, inactiveColor.b, 1.0);

        const activeColorFormatted = formatColorForHyprland(activeColor);
        const inactiveColorFormatted = formatColorForHyprland(inactiveColorWithFullOpacity);

        // Usar batch para aplicar todos los comandos de una vez
        const batchCommand = `keyword general:col.active_border ${activeColorFormatted} ; keyword general:col.inactive_border ${inactiveColorFormatted} ; keyword general:border_size ${Config.hyprlandBorderSize} ; keyword decoration:rounding ${Config.hyprlandRounding}`;

        console.log("HyprlandConfig: Aplicando configuración:", batchCommand);
        hyprctlProcess.command = ["hyprctl", "--batch", batchCommand];
        hyprctlProcess.running = true;
    }

    property Connections configConnections: Connections {
        target: Config.loader
        function onFileChanged() {
            applyHyprlandConfig();
        }
        function onLoaded() {
            applyHyprlandConfig();
        }
    }

    property Connections colorsConnections: Connections {
        target: Colors
        function onFileChanged() {
            applyHyprlandConfig();
        }
        function onLoaded() {
            applyHyprlandConfig();
        }
    }

    Component.onCompleted: {
        // Si ambos loaders ya están cargados, aplicar inmediatamente
        if (Config.loader.loaded && Colors.loaded) {
            applyHyprlandConfig();
        }
        // Si no, las conexiones onLoaded se encargarán
    }
}
