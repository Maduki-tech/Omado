import QtQuick
import qs.Commons
import qs.Ui

BarWidget {
    id: root
    moduleName: "maduki-tech.omado"

    function injectPanel() {
        var target = panelLoader.item
        if (!target)
            return
        if ("bar" in target)
            target.bar = root.bar
        if ("settings" in target)
            target.settings = root.settings
        if ("anchorItem" in target)
            target.anchorItem = button
        if ("hostWidget" in target)
            target.hostWidget = root
    }

    function togglePanel() {
        if (panelLoader.item && panelLoader.item.toggle)
            panelLoader.item.toggle()
    }

    readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false

    function open() {
        if (panelLoader.item && panelLoader.item.openFromHotkey)
            panelLoader.item.openFromHotkey()
    }

    function close() {
        if (panelLoader.item && panelLoader.item.close)
            panelLoader.item.close()
    }

    readonly property bool popoutSwitchClosing: panelLoader.item ? panelLoader.item.popoutSwitchClosing === true : false

    function closeForPopoutSwitch() {
        if (panelLoader.item && panelLoader.item.closeForPopoutSwitch)
            panelLoader.item.closeForPopoutSwitch()
    }

    visible: true
    implicitWidth: button.implicitWidth
    implicitHeight: button.implicitHeight

    onBarChanged: injectPanel()
    onSettingsChanged: injectPanel()

    Loader {
        id: panelLoader
        active: true
        source: Qt.resolvedUrl("Panel.qml")
        visible: false
        onLoaded: {
            root.injectPanel()
            Qt.callLater(root.injectPanel)
        }
    }

    BarIconButton {
        id: button
        anchors.fill: parent
        bar: root.bar
        text: panelLoader.item ? panelLoader.item.label : ""
        slotSize: Style.bar.statusSlot
        tooltipText: "Todo list"

        onPressed: function (b) {
            root.togglePanel()
        }
    }
}
