//@ pragma UseQApplication
import QtQuick
import Quickshell
import "./modules/bar/"
import "./modules/workspaces/"
import "./modules/notifications/"
import "./modules/wallpaper/"
import "./modules/notch/"
import "./modules/services/"
import "./modules/corners/"

ShellRoot {
    id: root

    // Multi-monitor support - create corners for each screen
    Variants {
        model: Quickshell.screens
        
        Loader {
            id: cornersLoader
            active: true
            required property ShellScreen modelData
            sourceComponent: ScreenCorners {
                screen: cornersLoader.modelData
            }
        }
    }

    // Wallpaper for all screens
    Variants {
        model: Quickshell.screens
        
        Loader {
            id: wallpaperLoader
            active: true
            required property ShellScreen modelData
            sourceComponent: Wallpaper {
                screen: wallpaperLoader.modelData
            }
        }
    }

    // Multi-monitor support - create bar for each screen
    Variants {
        model: {
            const screens = Quickshell.screens;
            const list = ConfigOptions.bar.screenList;
            if (!list || list.length === 0)
                return screens;
            return screens.filter(screen => list.includes(screen.name));
        }
        
        Loader {
            id: barLoader
            active: true
            required property ShellScreen modelData
            sourceComponent: Bar {
                screen: barLoader.modelData
            }
        }
    }

    // Multi-monitor support - create notch for each screen
    Variants {
        model: {
            const screens = Quickshell.screens;
            const list = ConfigOptions.bar.screenList;
            if (!list || list.length === 0)
                return screens;
            return screens.filter(screen => list.includes(screen.name));
        }
        
        Loader {
            id: notchLoader
            active: true
            required property ShellScreen modelData
            sourceComponent: NotchWindow {
                screen: notchLoader.modelData
            }
        }
    }

    Loader {
        active: true
        sourceComponent: NotificationPopup {}
    }
}
