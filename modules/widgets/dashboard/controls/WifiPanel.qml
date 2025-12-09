pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.modules.theme
import qs.modules.components
import qs.modules.services
import qs.config

Item {
    id: root

    Component.onCompleted: {
        NetworkService.rescanWifi();
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.rightMargin: 4
        spacing: 8

        // Titlebar
        PanelTitlebar {
            title: "Wi-Fi"
            statusText: NetworkService.wifiConnecting ? "Connecting..." : 
                       (NetworkService.wifiStatus === "limited" ? "Limited" : "")
            statusColor: NetworkService.wifiStatus === "limited" ? Colors.warning : Colors.primary
            showSpinner: NetworkService.wifiScanning
            showToggle: true
            toggleChecked: NetworkService.wifiStatus !== "disabled"
            
            actions: [
                {
                    icon: Icons.globe,
                    tooltip: "Open captive portal",
                    enabled: NetworkService.wifiStatus === "limited",
                    onClicked: function() { NetworkService.openPublicWifiPortal(); }
                },
                {
                    icon: Icons.gear,
                    tooltip: "Network settings",
                    onClicked: function() { Quickshell.execDetached(["nm-connection-editor"]); }
                },
                {
                    icon: Icons.sync,
                    tooltip: "Rescan networks",
                    enabled: !NetworkService.wifiScanning && NetworkService.wifiEnabled,
                    onClicked: function() { NetworkService.rescanWifi(); }
                }
            ]
            
            onToggleChanged: checked => {
                NetworkService.enableWifi(checked);
                if (checked) {
                    NetworkService.rescanWifi();
                }
            }
        }

        // Network list
        ListView {
            id: networkList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 4

            model: NetworkService.friendlyWifiNetworks

            delegate: WifiNetworkItem {
                required property var modelData
                width: networkList.width - 4
                network: modelData
            }

            // Empty state
            Text {
                anchors.centerIn: parent
                visible: networkList.count === 0 && !NetworkService.wifiScanning
                text: NetworkService.wifiEnabled ? "No networks found" : "Wi-Fi is disabled"
                font.family: Config.theme.font
                font.pixelSize: Config.theme.fontSize
                color: Colors.overSurfaceVariant
            }
        }
    }
}
