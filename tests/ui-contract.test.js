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
  includes(panel, "onClicked: root.removeTodo(index)");
  includes(panel, "root.toggleTodo(index)");
  includes(panel, "root.startEdit(index)");
  includes(panel, 'text: "Clear completed"');
});

test("panel handles required keyboard actions", () => {
  for (const keyName of ["Qt.Key_Return", "Qt.Key_Enter", "Qt.Key_Escape", "Qt.Key_Tab", "Qt.Key_Backtab"]) {
    includes(panel, keyName);
  }

  includes(panel, "onCloseRequested: root.close()");
  includes(panel, "onTabRequested: function (direction)");
  includes(panel, "root.switchPanel(event.key === Qt.Key_Backtab ? -1 : 1)");
});

test("panel renders empty and remaining-task states", () => {
  includes(panel, 'text: "No tasks yet"');
  includes(panel, 'text: root.remaining + " remaining"');
  includes(panel, "visible: remaining < todoModel.count");
});
