pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config

Singleton {
    id: root

    // Check if an app is pinned
    function isPinned(appId) {
        const pinnedApps = Config.dock?.pinnedApps || [];
        return pinnedApps.some(id => id.toLowerCase() === appId.toLowerCase());
    }

    // Toggle pin status of an app
    function togglePin(appId) {
        let pinnedApps = Config.dock?.pinnedApps || [];
        const normalizedAppId = appId.toLowerCase();
        
        if (isPinned(appId)) {
            // Remove from pinned
            Config.dock.pinnedApps = pinnedApps.filter(id => id.toLowerCase() !== normalizedAppId);
        } else {
            // Add to pinned
            Config.dock.pinnedApps = pinnedApps.concat([appId]);
        }
    }

    // Get desktop entry for an app
    function getDesktopEntry(appId) {
        if (!appId) return null;
        return DesktopEntries.heuristicLookup(appId) || null;
    }

    // Launch an app by its ID
    function launchApp(appId) {
        const entry = getDesktopEntry(appId);
        if (entry) {
            entry.execute();
        }
    }

    // Main list of apps combining pinned and running apps
    property list<var> apps: {
        var map = new Map();

        // Get config values
        const pinnedApps = Config.dock?.pinnedApps ?? [];
        const ignoredRegexStrings = Config.dock?.ignoredAppRegexes ?? [];
        const ignoredRegexes = ignoredRegexStrings.map(pattern => new RegExp(pattern, "i"));

        // Add pinned apps first
        for (const appId of pinnedApps) {
            const key = appId.toLowerCase();
            if (!map.has(key)) {
                map.set(key, {
                    appId: appId,
                    pinned: true,
                    toplevels: []
                });
            }
        }

        // Add separator if there are pinned apps
        if (pinnedApps.length > 0) {
            map.set("SEPARATOR", { 
                appId: "SEPARATOR", 
                pinned: false, 
                toplevels: [] 
            });
        }

        // Add running apps from ToplevelManager
        for (const toplevel of ToplevelManager.toplevels.values) {
            // Skip ignored apps
            if (ignoredRegexes.some(re => re.test(toplevel.appId))) continue;
            
            const key = toplevel.appId.toLowerCase();
            
            if (!map.has(key)) {
                map.set(key, {
                    appId: toplevel.appId,
                    pinned: false,
                    toplevels: []
                });
            }
            
            map.get(key).toplevels.push(toplevel);
        }

        // Convert to list of TaskbarAppEntry objects
        var values = [];
        for (const [key, value] of map) {
            values.push(appEntryComp.createObject(null, { 
                appId: value.appId, 
                toplevels: value.toplevels, 
                pinned: value.pinned 
            }));
        }

        return values;
    }

    // Component for TaskbarAppEntry
    component TaskbarAppEntry: QtObject {
        required property string appId
        required property list<var> toplevels
        required property bool pinned
    }
    
    Component {
        id: appEntryComp
        TaskbarAppEntry {}
    }
}
