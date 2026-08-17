import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model

Panel {
    id: root
    moduleName: "maduki-tech.omado"

    property var anchorItem: null
    property var hostWidget: null
    readonly property var barIdentity: hostWidget || root
    readonly property string label: ""
    property int remaining: 0

    readonly property string stateDir: Quickshell.env("HOME") + "/.local/state/omarchy/settings"
    readonly property string todoPath: stateDir + "/maduki-tech.todo.json"

    ListModel {
        id: todoModel
    }

    function openFromHotkey() {
        root.controller.show();
        Qt.callLater(function () {
            if (root.opened)
                root.setCenterHoverRevealSuppressed(true);
        });
    }

    function close() {
        setCenterHoverRevealSuppressed(false);
        root.controller.hide();
    }

    function toggle() {
        if (root.opened)
            root.close();
        else
            root.openFromHotkey();
    }

    function closeForPopoutSwitch() {
        root.close();
    }

    function switchPanel(direction) {
        if (root.bar && typeof root.bar.switchPanelFrom === "function")
            return root.bar.switchPanelFrom(root.barIdentity, direction);
        return false;
    }

    function setCenterHoverRevealSuppressed(value) {
        if (root.bar && "centerHoverRevealSuppressed" in root.bar)
            root.bar.centerHoverRevealSuppressed = value;
    }

    function recount() {
        var n = 0;
        for (var i = 0; i < todoModel.count; ++i)
            if (!todoModel.get(i).completed)
                n++;
        remaining = n;
    }

    function loadTodos(raw) {
        var todos = Model.parseTodos(raw);
        todoModel.clear();
        for (var i = 0; i < todos.length; ++i)
            todoModel.append(todos[i]);
        recount();
    }

    function saveTodos() {
        var todos = [];
        for (var i = 0; i < todoModel.count; ++i) {
            var item = todoModel.get(i);
            todos.push({
                title: item.title,
                completed: item.completed
            });
        }
        todoFile.setText(JSON.stringify(todos, null, 2) + "\n");
    }

    function addTodo() {
        var title = todoField.text.replace(/^\s+|\s+$/g, "");
        if (title === "")
            return;
        todoModel.insert(0, {
            title: title,
            completed: false
        });
        todoField.clear();
        saveTodos();
        recount();
        todoField.forceActiveFocus();
    }

    function toggleTodo(index) {
        if (index < 0 || index >= todoModel.count)
            return;
        todoModel.setProperty(index, "completed", !todoModel.get(index).completed);
        saveTodos();
        recount();
    }

    function removeTodo(index) {
        if (index < 0 || index >= todoModel.count)
            return;
        todoModel.remove(index);
        saveTodos();
        recount();
    }

    function clearCompleted() {
        var removed = false;
        for (var i = todoModel.count - 1; i >= 0; --i) {
            if (todoModel.get(i).completed) {
                todoModel.remove(i);
                removed = true;
            }
        }
        if (removed) {
            saveTodos();
            recount();
        }
    }

    FileView {
        id: todoFile
        path: root.todoPath
        watchChanges: true
        atomicWrites: true
        printErrors: false
        onLoaded: root.loadTodos(text())
        onLoadFailed: root.loadTodos("[]")
        onFileChanged: reload()
    }

    Process {
        id: ensureDirsProc
        command: ["mkdir", "-p", root.stateDir]
        onExited: todoFile.reload()
    }

    Component.onCompleted: {
        ensureDirsProc.running = true;
    }

    KeyboardPanel {
        id: panel
        anchorItem: root.anchorItem
        owner: root.barIdentity
        bar: root.bar
        open: root.opened
        centerOnBar: false
        focusTarget: todoField
        contentWidth: panel.fittedContentWidth(Style.space(440))
        contentHeight: panel.fittedContentHeight(todoColumn.implicitHeight)

        PanelKeyCatcher {
            id: keyCatcher
            anchors.fill: parent
            blocked: todoField.activeFocus
            onCloseRequested: root.close()
            onTabRequested: function (direction) {
                root.switchPanel(direction);
            }

            Flickable {
                id: todoScroll
                anchors.fill: parent
                contentWidth: width
                contentHeight: todoColumn.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                interactive: contentHeight > height

                Column {
                    id: todoColumn
                    width: todoScroll.width
                    spacing: Style.space(12)

                    Row {
                        width: parent.width
                        leftPadding: Style.space(16)
                        rightPadding: Style.space(16)
                        spacing: Style.space(10)

                        Text {
                            text: root.label
                            color: root.bar.foreground
                            font.family: root.bar.fontFamily
                            font.pixelSize: Style.font.display
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            spacing: Style.space(2)
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: "TODO LIST"
                                color: root.bar.foreground
                                font.family: root.bar.fontFamily
                                font.pixelSize: Style.font.title
                                font.bold: true
                            }
                            Text {
                                text: root.remaining + " remaining"
                                color: Qt.darker(root.bar.foreground, 1.5)
                                font.family: root.bar.fontFamily
                                font.pixelSize: Style.font.bodySmall
                            }
                        }
                    }

                    Row {
                        width: parent.width
                        leftPadding: Style.space(16)
                        rightPadding: Style.space(16)
                        spacing: Style.space(8)

                        TextField {
                            id: todoField
                            width: parent.width - Style.space(80)
                            placeholderText: "Add a task…"
                            foreground: root.bar.foreground
                            font.family: root.bar.fontFamily

                            Keys.onPressed: function (event) {
                                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    root.addTodo();
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Escape) {
                                    root.close();
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
                                    root.switchPanel(event.key === Qt.Key_Backtab ? -1 : 1);
                                    event.accepted = true;
                                }
                            }
                        }

                        Rectangle {
                            width: Style.space(40)
                            height: todoField.height
                            radius: Style.cornerRadius
                            color: addArea.containsMouse ? Style.hoverFillFor(root.bar.foreground, Color.accent) : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: ""
                                color: root.bar.foreground
                                font.family: root.bar.fontFamily
                                font.pixelSize: Style.font.title
                            }

                            MouseArea {
                                id: addArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.addTodo()
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width - Style.space(32)
                        x: Style.space(16)
                        height: Style.spacing.hairline
                        color: root.bar.foreground
                        opacity: 0.12
                    }

                    ListView {
                        id: todoList
                        width: parent.width
                        height: Math.max(Style.space(48), contentHeight)
                        interactive: false
                        model: todoModel
                        spacing: Style.space(4)

                        delegate: Rectangle {
                            required property int index
                            required property string title
                            required property bool completed

                            width: todoList.width - Style.space(32)
                            x: Style.space(16)
                            height: Style.space(46)
                            radius: Style.cornerRadius
                            color: rowArea.containsMouse ? Style.hoverFillFor(root.bar.foreground, Color.accent) : "transparent"

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: Style.space(12)
                                anchors.rightMargin: Style.space(8)
                                spacing: Style.space(10)

                                Text {
                                    text: completed ? "󰄲" : "󰄱"
                                    color: completed ? Color.accent : root.bar.foreground
                                    font.family: root.bar.fontFamily
                                    font.pixelSize: Style.font.title
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    width: parent.width - Style.space(72)
                                    text: title
                                    color: completed ? Qt.darker(root.bar.foreground, 1.6) : root.bar.foreground
                                    font.family: root.bar.fontFamily
                                    font.pixelSize: Style.font.body
                                    font.strikeout: completed
                                    elide: Text.ElideRight
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                            }

                            Rectangle {
                                id: trashButton
                                width: Style.space(32)
                                height: Style.space(32)
                                x: parent.width - width - Style.space(8)
                                y: (parent.height - height) / 2
                                z: 10
                                radius: Style.cornerRadius
                                color: trashArea.containsMouse ? Style.hoverFillFor(root.bar.foreground, Color.accent) : "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰆴"
                                    color: trashArea.containsMouse ? Color.accent : Qt.darker(root.bar.foreground, 1.4)
                                    font.family: root.bar.fontFamily
                                    font.pixelSize: Style.font.body
                                }

                                MouseArea {
                                    id: trashArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.removeTodo(index)
                                }
                            }

                            MouseArea {
                                id: rowArea
                                anchors.fill: parent
                                anchors.rightMargin: Style.space(48)
                                z: -1
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.toggleTodo(index)
                            }
                        }
                    }

                    Text {
                        visible: todoModel.count === 0
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        text: "No tasks yet"
                        color: Qt.darker(root.bar.foreground, 1.5)
                        font.family: root.bar.fontFamily
                        font.pixelSize: Style.font.body
                        font.italic: true
                    }

                    Row {
                        visible: remaining < todoModel.count
                        width: parent.width
                        leftPadding: Style.space(16)
                        rightPadding: Style.space(16)

                        Text {
                            text: "Clear completed"
                            color: clearArea.containsMouse ? Color.accent : Qt.darker(root.bar.foreground, 1.4)
                            font.family: root.bar.fontFamily
                            font.pixelSize: Style.font.bodySmall

                            MouseArea {
                                id: clearArea
                                anchors.fill: parent
                                anchors.margins: -Style.space(6)
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.clearCompleted()
                            }
                        }
                    }
                }
            }
        }
    }
}
