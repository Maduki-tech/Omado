const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

const root = path.resolve(__dirname, "..");
const panel = fs.readFileSync(path.join(root, "Panel.qml"), "utf8");
const barWidget = fs.readFileSync(path.join(root, "BarWidget.qml"), "utf8");

function includes(source, fragment) {
  assert.equal(source.includes(fragment), true, `missing UI contract: ${fragment}`);
}

test("panel keeps required plugin wiring", () => {
  includes(panel, 'moduleName: "maduki-tech.omado"');
  includes(panel, "readonly property string label:");
  includes(panel, 'property var anchorItem: null');
  includes(panel, 'property var hostWidget: null');
  includes(panel, 'path: root.todoPath');
  includes(panel, 'onLoaded: root.loadTodos(text())');
});

test("bar widget loads and injects panel dependencies", () => {
  includes(barWidget, 'source: Qt.resolvedUrl("Panel.qml")');
  includes(barWidget, "root.injectPanel()");
  includes(barWidget, "target.bar = root.bar");
  includes(barWidget, "target.anchorItem = button");
  includes(barWidget, "target.hostWidget = root");
  includes(barWidget, 'tooltipText: "Todo list"');
});

test("panel exposes core todo interactions", () => {
  for (const functionName of [
    "addTodo",
    "addTodoTitle",
    "toggleTodo",
    "removeTodo",
    "clearCompleted",
    "startEdit",
    "commitEdit",
    "cancelEdit"
  ]) {
    includes(panel, `function ${functionName}(`);
  }

  includes(panel, "onClicked: root.addTodo()");
  includes(panel, "root.removeTodo(index);");
  includes(panel, "root.selectTodo(index, true)");
  includes(panel, "root.toggleTodo(index)");
  includes(panel, "root.startEdit(index)");
  includes(panel, 'todoModel.move(index, destination, 1)');
  includes(panel, 'text: "Clear completed"');
});

test("panel handles required keyboard actions", () => {
  for (const keyName of [
    "Qt.Key_Return",
    "Qt.Key_Enter",
    "Qt.Key_Escape",
    "Qt.Key_Tab",
    "Qt.Key_Backtab",
    "Qt.ShiftModifier",
  ]) {
    includes(panel, keyName);
  }

  includes(panel, "onCloseRequested: root.close()");
  includes(panel, "onTabRequested: function (direction)");
  includes(panel, "todoField.forceActiveFocus()");
  includes(panel, "keyCatcher.forceActiveFocus()");
  includes(panel, "root.switchPanel(1)");
  includes(panel, "root.switchPanel(backwards ? -1 : 1)");
});

test("todo keyboard navigation uses a bounded selection and existing actions", () => {
  includes(panel, "property int selectedIndex: -1");
  includes(panel, "function normalizeSelection()");
  includes(panel, "function moveSelection(delta)");
  includes(panel, "selectedIndex = ((selectedIndex + delta) % todoModel.count + todoModel.count) % todoModel.count;");
  includes(panel, "currentIndex: root.selectedIndex");
  includes(panel, "onMoveRequested: function (dx, dy)");
  includes(panel, "root.moveSelection(dy)");
  includes(panel, "onActivateRequested: root.toggleTodo(root.selectedIndex)");
  includes(panel, "onDeleteRequested: {");
  includes(panel, "root.removeTodo(root.selectedIndex);");
  includes(panel, 'onTextKey: function (text)');
  includes(panel, 'if (text === "e")');
  includes(panel, "root.startEdit(root.selectedIndex)");
  includes(panel, "Style.selectedFillFor(root.bar.foreground, Color.accent)");
  includes(panel, "function ensureSelectedVisible()");
  includes(panel, "row.mapToItem(todoScroll.contentItem, 0, 0)");
});

test("adding a todo selects the new top row without moving focus from the add field", () => {
  const start = panel.indexOf("function addTodoTitle(text)");
  const end = panel.indexOf("\n    function addTodo()", start);
  assert.notEqual(start, -1);
  assert.notEqual(end, -1);
  const addTodoTitle = panel.slice(start, end);

  includes(addTodoTitle, "todoModel.insert(0,");
  includes(addTodoTitle, "selectedIndex = 0;");
  assert.equal(addTodoTitle.includes("forceActiveFocus"), false);
  includes(panel, "todoField.forceActiveFocus()");
});

test("panel exposes the global Quick Add overlay", () => {
  includes(panel, "import Quickshell.Hyprland");
  includes(panel, "GlobalShortcut");
  includes(panel, 'appid: "maduki-tech.omado"');
  includes(panel, 'name: "quick-add"');
  includes(panel, "function openQuickAdd()");
  includes(panel, "function closeQuickAdd()");
  includes(panel, "readonly property var hostWindow:");
  includes(panel, "readonly property var hostScreen:");
  includes(panel, "screen: root.hostScreen");
  includes(panel, "root.quickAddOpen && !!root.hostScreen");
  assert.equal(panel.includes("quickAddWindow.screen"), false);
  includes(panel, "WlrLayer.Overlay");
  includes(panel, "WlrKeyboardFocus.None");
  includes(panel, "Hyprland.focusedMonitor");
  includes(panel, 'WlrLayershell.namespace: "maduki-tech-omado-quick-add"');
  includes(panel, 'text: "QUICK ADD"');
  includes(panel, "root.addTodoTitle(text)");
});

test("panel uses the scoped bar API for hover suppression", () => {
  includes(panel, 'typeof root.bar.setCenterHoverRevealSuppressed === "function"');
  includes(panel, "root.bar.setCenterHoverRevealSuppressed(value)");
  assert.doesNotMatch(panel, /root\.bar\.centerHoverRevealSuppressed\s*=/);
});

test("panel renders empty and remaining-task states", () => {
  includes(panel, 'text: "No tasks yet"');
  includes(panel, 'text: root.remaining + " remaining"');
  includes(panel, "visible: remaining < todoModel.count");
});
