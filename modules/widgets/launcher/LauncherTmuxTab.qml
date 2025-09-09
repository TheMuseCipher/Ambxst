import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.modules.theme
import qs.modules.components
import qs.modules.globals
import qs.modules.services
import qs.config

Rectangle {
    id: root
    focus: true

    property string searchText: ""
    property bool showResults: searchText.length > 0
    property int selectedIndex: -1
    property var tmuxSessions: []
    property alias filteredSessions: listModel.sessions
    
    // Delete mode state
    property bool deleteMode: false
    property string sessionToDelete: ""
    property int originalSelectedIndex: -1
    
    signal itemSelected

    // Model para hacer la lista observable
    QtObject {
        id: listModel
        property var sessions: []
        
        function updateSessions(newSessions) {
            sessions = newSessions;
            console.log("DEBUG: listModel updated with", sessions.length, "sessions");
        }
    }

    onSelectedIndexChanged: {
        if (selectedIndex === -1 && resultsList.count > 0) {
            resultsList.positionViewAtIndex(0, ListView.Beginning);
        }
    }

    onSearchTextChanged: {
        updateFilteredSessions();
    }

    function clearSearch() {
        searchText = "";
        selectedIndex = -1;
        searchInput.focusInput();
        updateFilteredSessions();
    }

    function focusSearchInput() {
        searchInput.focusInput();
    }

    function cancelDeleteModeFromExternal() {
        if (deleteMode) {
            console.log("DEBUG: Canceling delete mode from external source (tab change)");
            cancelDeleteMode();
        }
    }

    function updateFilteredSessions() {
        console.log("DEBUG: updateFilteredSessions called. searchText:", searchText, "tmuxSessions.length:", tmuxSessions.length);
        
        var newFilteredSessions = [];
        
        // Filtrar sesiones que coincidan con el texto de búsqueda (sin considerar deleteMode aquí)
        if (searchText.length === 0) {
            newFilteredSessions = tmuxSessions.slice(); // Copia del array
        } else {
            newFilteredSessions = tmuxSessions.filter(function(session) {
                return session.name.toLowerCase().includes(searchText.toLowerCase());
            });
            
            // Verificar si existe una sesión con el nombre exacto
            let exactMatch = tmuxSessions.find(function(session) {
                return session.name.toLowerCase() === searchText.toLowerCase();
            });
            
            // Si no hay coincidencia exacta y hay texto de búsqueda, agregar opción para crear la sesión específica
            if (!exactMatch && searchText.length > 0) {
                newFilteredSessions.push({
                    name: `Create session "${searchText}"`,
                    isCreateSpecificButton: true,
                    sessionNameToCreate: searchText,
                    icon: "terminal"
                });
            }
        }
        
        console.log("DEBUG: newFilteredSessions after filter:", newFilteredSessions.length);
        
        // Solo agregar el botón "Create new session" cuando NO hay texto de búsqueda y NO estamos en modo eliminar
        if (searchText.length === 0 && !deleteMode) {
            newFilteredSessions.push({
                name: "Create new session",
                isCreateButton: true,
                icon: "terminal"
            });
        }
        
        console.log("DEBUG: newFilteredSessions after adding create button:", newFilteredSessions.length);
        
        // Actualizar el modelo
        listModel.updateSessions(newFilteredSessions);
        
        // Auto-highlight first item when text is entered, pero NO en modo eliminar
        if (!deleteMode) {
            if (searchText.length > 0 && newFilteredSessions.length > 0) {
                selectedIndex = 0;
                resultsList.currentIndex = 0;
            } else if (searchText.length === 0) {
                selectedIndex = -1;
                resultsList.currentIndex = -1;
            }
        }
        
        console.log("DEBUG: Final selectedIndex:", selectedIndex, "resultsList will have count:", newFilteredSessions.length);
    }

    function enterDeleteMode(sessionName) {
        console.log("DEBUG: Entering delete mode for session:", sessionName);
        originalSelectedIndex = selectedIndex; // Store the current index
        deleteMode = true;
        sessionToDelete = sessionName;
        // Quitar focus del SearchInput para que el componente root pueda capturar Y/N
        root.forceActiveFocus();
        // No necesito llamar updateFilteredSessions porque el delegate se actualiza automáticamente
    }

    function cancelDeleteMode() {
        console.log("DEBUG: Canceling delete mode");
        deleteMode = false;
        sessionToDelete = "";
        // Devolver focus al SearchInput
        searchInput.focusInput();
        updateFilteredSessions();
        // Restore the original selectedIndex
        selectedIndex = originalSelectedIndex;
        resultsList.currentIndex = originalSelectedIndex;
        originalSelectedIndex = -1;
    }

    function confirmDeleteSession() {
        console.log("DEBUG: Confirming delete for session:", sessionToDelete);
        killProcess.command = ["tmux", "kill-session", "-t", sessionToDelete];
        killProcess.running = true;
        cancelDeleteMode();
    }

    function refreshTmuxSessions() {
        tmuxProcess.running = true;
    }

    function createTmuxSession(sessionName) {
        if (sessionName) {
            // Crear la sesión con nombre específico
            createProcess.command = ["bash", "-c", `kitty -e tmux new -s "${sessionName}" & disown`];
        } else {
            // Crear sesión sin nombre (tmux se encarga del nombre automático)
            createProcess.command = ["bash", "-c", `kitty -e tmux & disown`];
        }
        createProcess.running = true;
        root.itemSelected(); // Cerrar el notch
    }

    function attachToSession(sessionName) {
        // Ejecutar terminal con tmux attach de forma independiente (detached)
        attachProcess.command = ["bash", "-c", `kitty -e tmux attach-session -t "${sessionName}" & disown`];
        attachProcess.running = true;
    }

    implicitWidth: 400
    implicitHeight: mainLayout.implicitHeight
    color: "transparent"

    Behavior on height {
        NumberAnimation {
            duration: Config.animDuration
            easing.type: Easing.OutQuart
        }
    }

    // Proceso para obtener lista de sesiones de tmux
    Process {
        id: tmuxProcess
        command: ["tmux", "list-sessions", "-F", "#{session_name}"]
        running: false

        stdout: StdioCollector {
            id: tmuxCollector
            waitForEnd: true

            onStreamFinished: {
                let sessions = [];
                let lines = text.trim().split('\n');
                for (let line of lines) {
                    if (line.trim().length > 0) {
                        sessions.push({
                            name: line.trim(),
                            isCreateButton: false,
                            icon: "terminal"
                        });
                    }
                }
                root.tmuxSessions = sessions;
                root.updateFilteredSessions();
            }
        }

        onExited: function (exitCode) {
            if (exitCode !== 0) {
                // No hay sesiones o tmux no está disponible
                root.tmuxSessions = [];
                root.updateFilteredSessions();
            }
        }
    }

    // Proceso para crear nuevas sesiones
    Process {
        id: createProcess
        running: false

        onExited: function (code) {
            if (code === 0) {
                // Sesión creada exitosamente, refrescar la lista
                root.refreshTmuxSessions();
            }
        }
    }

    // Proceso para abrir terminal con tmux attach
    Process {
        id: attachProcess
        running: false
        
        onStarted: function() {
            root.itemSelected();
        }
    }

    // Proceso para eliminar sesiones de tmux
    Process {
        id: killProcess
        running: false
        
        onExited: function(code) {
            console.log("DEBUG: Kill session completed with code:", code);
            if (code === 0) {
                // Sesión eliminada exitosamente, refrescar la lista
                root.refreshTmuxSessions();
            }
        }
    }

    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        spacing: 8

        // Search input
        SearchInput {
            id: searchInput
            Layout.fillWidth: true
            text: root.searchText
            placeholderText: "Search or create tmux session..."
            iconText: ""

            onSearchTextChanged: text => {
                root.searchText = text;
            }

            onAccepted: {
                if (root.deleteMode) {
                    // En modo eliminar, Enter equivale a "N" (no eliminar)
                    console.log("DEBUG: Enter in delete mode - canceling");
                    root.cancelDeleteMode();
                } else {
                    console.log("DEBUG: Enter pressed! searchText:", root.searchText, "selectedIndex:", root.selectedIndex, "resultsList.count:", resultsList.count);
                    
                    if (root.selectedIndex >= 0 && root.selectedIndex < resultsList.count) {
                        let selectedSession = root.filteredSessions[root.selectedIndex];
                        console.log("DEBUG: Selected session:", selectedSession);
                        if (selectedSession) {
                            if (selectedSession.isCreateSpecificButton) {
                                console.log("DEBUG: Creating specific session:", selectedSession.sessionNameToCreate);
                                root.createTmuxSession(selectedSession.sessionNameToCreate);
                            } else if (selectedSession.isCreateButton) {
                                console.log("DEBUG: Creating new session via create button");
                                root.createTmuxSession();
                            } else {
                                console.log("DEBUG: Attaching to existing session:", selectedSession.name);
                                root.attachToSession(selectedSession.name);
                            }
                        }
                    } else {
                        console.log("DEBUG: No action taken - selectedIndex:", root.selectedIndex, "count:", resultsList.count);
                    }
                }
            }

            onShiftAccepted: {
                console.log("DEBUG: Shift+Enter pressed! selectedIndex:", root.selectedIndex, "deleteMode:", root.deleteMode);
                
                if (!root.deleteMode && root.selectedIndex >= 0 && root.selectedIndex < resultsList.count) {
                    let selectedSession = root.filteredSessions[root.selectedIndex];
                    console.log("DEBUG: Selected session for deletion:", selectedSession);
                    if (selectedSession && !selectedSession.isCreateButton && !selectedSession.isCreateSpecificButton) {
                        // Solo permitir eliminar sesiones reales, no botones de crear
                        root.enterDeleteMode(selectedSession.name);
                    }
                }
            }

            onEscapePressed: {
                if (!root.deleteMode) {
                    // Solo cerrar el notch si NO estamos en modo eliminar
                    root.itemSelected();
                }
                // Si estamos en modo eliminar, no hacer nada aquí
                // El handler global del root se encargará
            }

            onDownPressed: {
                if (!root.deleteMode && resultsList.count > 0) {
                    if (root.selectedIndex === -1) {
                        root.selectedIndex = 0;
                        resultsList.currentIndex = 0;
                    } else if (root.selectedIndex < resultsList.count - 1) {
                        root.selectedIndex++;
                        resultsList.currentIndex = root.selectedIndex;
                    }
                }
            }

            onUpPressed: {
                if (!root.deleteMode) {
                    if (root.selectedIndex > 0) {
                        root.selectedIndex--;
                        resultsList.currentIndex = root.selectedIndex;
                    } else if (root.selectedIndex === 0 && root.searchText.length === 0) {
                        root.selectedIndex = -1;
                        resultsList.currentIndex = -1;
                    }
                }
            }

            onPageDownPressed: {
                if (resultsList.count > 0) {
                    let visibleItems = Math.floor(resultsList.height / 48);
                    let newIndex = Math.min(root.selectedIndex + visibleItems, resultsList.count - 1);
                    if (root.selectedIndex === -1) {
                        newIndex = Math.min(visibleItems - 1, resultsList.count - 1);
                    }
                    root.selectedIndex = newIndex;
                    resultsList.currentIndex = root.selectedIndex;
                }
            }

            onPageUpPressed: {
                if (resultsList.count > 0) {
                    let visibleItems = Math.floor(resultsList.height / 48);
                    let newIndex = Math.max(root.selectedIndex - visibleItems, 0);
                    if (root.selectedIndex === -1) {
                        newIndex = Math.max(resultsList.count - visibleItems, 0);
                    }
                    root.selectedIndex = newIndex;
                    resultsList.currentIndex = root.selectedIndex;
                }
            }

            onHomePressed: {
                if (resultsList.count > 0) {
                    root.selectedIndex = 0;
                    resultsList.currentIndex = 0;
                }
            }

            onEndPressed: {
                if (resultsList.count > 0) {
                    root.selectedIndex = resultsList.count - 1;
                    resultsList.currentIndex = root.selectedIndex;
                }
            }
        }

        // Results list
        ListView {
            id: resultsList
            Layout.fillWidth: true
            Layout.preferredHeight: 5 * 48
            visible: true
            clip: true

            model: root.filteredSessions
            currentIndex: root.selectedIndex

            // Sync currentIndex with selectedIndex
            onCurrentIndexChanged: {
                if (currentIndex !== root.selectedIndex) {
                    root.selectedIndex = currentIndex;
                }
            }

            delegate: Rectangle {
                required property var modelData
                required property int index

                width: resultsList.width
                height: 48
                color: "transparent"
                radius: 16

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true

                    onEntered: {
                        root.selectedIndex = index;
                        resultsList.currentIndex = index;
                    }
                    onClicked: {
                        if (modelData.isCreateSpecificButton) {
                            root.createTmuxSession(modelData.sessionNameToCreate);
                        } else if (modelData.isCreateButton) {
                            root.createTmuxSession();
                        } else {
                            root.attachToSession(modelData.name);
                        }
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 12

                    // Icono
                    Rectangle {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        color: {
                            if (root.deleteMode && modelData.name === root.sessionToDelete) {
                                return Colors.adapter.error;
                            } else if (modelData.isCreateButton) {
                                return Colors.adapter.primary;
                            } else {
                                return Colors.adapter.surface;
                            }
                        }
                        radius: 6
                        
                        Behavior on color {
                            ColorAnimation {
                                duration: Config.animDuration / 2
                                easing.type: Easing.OutQuart
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: ""  // Icono de terminal
                            color: {
                                if (root.deleteMode && modelData.name === root.sessionToDelete) {
                                    return Colors.adapter.errorContainer;
                                } else if (modelData.isCreateButton) {
                                    return Colors.background;
                                } else {
                                    return Colors.adapter.overSurface;
                                }
                            }
                            font.family: Icons.font
                            font.pixelSize: 16
                            
                            Behavior on color {
                                ColorAnimation {
                                    duration: Config.animDuration / 2
                                    easing.type: Easing.OutQuart
                                }
                            }
                        }
                    }

                    // Texto
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            Layout.fillWidth: true
                            text: {
                                // Si estamos en modo eliminar y este es el item seleccionado
                                if (root.deleteMode && modelData.name === root.sessionToDelete) {
                                    return `Exit "${root.sessionToDelete}"? (y/N)`;
                                } else {
                                    return modelData.name;
                                }
                            }
                            color: (root.deleteMode && modelData.name === root.sessionToDelete) ? Colors.adapter.errorContainer : Colors.adapter.overBackground
                            font.family: Config.theme.font
                            font.pixelSize: Config.theme.fontSize
                            font.weight: modelData.isCreateButton ? Font.Medium : Font.Bold
                            elide: Text.ElideRight
                            
                            Behavior on color {
                                ColorAnimation {
                                    duration: Config.animDuration / 2
                                    easing.type: Easing.OutQuart
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.isCreateButton ? "Create a new tmux session" : "Tmux session"
                            color: Colors.adapter.overBackground
                            opacity: 0.7
                            font.family: Config.theme.font
                            font.pixelSize: Config.theme.fontSize - 2
                            elide: Text.ElideRight
                            visible: !modelData.isCreateButton || root.searchText.length === 0
                        }
                    }
                }
            }

            highlight: Rectangle {
                color: root.deleteMode ? Colors.adapter.error : Colors.adapter.primary
                opacity: root.deleteMode ? 1.0 : 0.2
                radius: Config.roundness > 0 ? Config.roundness + 4 : 0
                visible: root.selectedIndex >= 0
                
                Behavior on color {
                    ColorAnimation {
                        duration: Config.animDuration / 2
                        easing.type: Easing.OutQuart
                    }
                }
                
                Behavior on opacity {
                    NumberAnimation {
                        duration: Config.animDuration / 2
                        easing.type: Easing.OutQuart
                    }
                }
            }

            highlightMoveDuration: Config.animDuration / 2
            highlightMoveVelocity: -1
        }
    }

    Component.onCompleted: {
        // Cargar sesiones de tmux al inicializar
        refreshTmuxSessions();
        Qt.callLater(() => {
            focusSearchInput();
        });
    }

    // Handler de teclas global para manejar Y/N/Enter/Escape en modo eliminar
    Keys.onPressed: event => {
        if (root.deleteMode) {
            if (event.key === Qt.Key_Y) {
                console.log("DEBUG: Y pressed - confirming delete");
                root.confirmDeleteSession();
                event.accepted = true;
            } else if (event.key === Qt.Key_N) {
                console.log("DEBUG: N pressed - canceling delete");
                root.cancelDeleteMode();
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                console.log("DEBUG: Enter pressed in delete mode - defaulting to N (cancel)");
                root.cancelDeleteMode();
                event.accepted = true;
            } else if (event.key === Qt.Key_Escape) {
                console.log("DEBUG: Escape pressed in delete mode - canceling without closing notch");
                root.cancelDeleteMode();
                event.accepted = true;
            }
        }
    }

    // Monitor cambios en deleteMode para cancelar al cambiar tabs
    onDeleteModeChanged: {
        if (!deleteMode) {
            console.log("DEBUG: Delete mode ended");
        }
    }
}
