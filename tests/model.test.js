const test = require("node:test");
const assert = require("node:assert/strict");

const { parseTodos } = require("../Model.js");

test("parses valid todos and normalizes titles", () => {
  assert.deepEqual(parseTodos(JSON.stringify([
    { title: "  Buy milk  ", completed: true },
    { title: "Read book", completed: false }
  ])), [
    { title: "Read book", completed: false },
    { title: "Buy milk", completed: true }
  ]);
});

test("defaults completed to false unless it is exactly true", () => {
  assert.deepEqual(parseTodos(JSON.stringify([
    { title: "One", completed: 1 },
    { title: "Two", completed: "true" },
    { title: "Three", completed: true }
  ])), [
    { title: "One", completed: false },
    { title: "Two", completed: false },
    { title: "Three", completed: true }
  ]);
});

test("ignores invalid, blank, and non-object entries", () => {
  assert.deepEqual(parseTodos(JSON.stringify([
    null,
    42,
    { title: 123 },
    { title: "   " },
    { title: "Valid" }
  ])), [{ title: "Valid", completed: false }]);
});

test("returns an empty list for invalid or non-array JSON", () => {
  assert.deepEqual(parseTodos("not json"), []);
  assert.deepEqual(parseTodos(JSON.stringify({ title: "Todo" })), []);
  assert.deepEqual(parseTodos(""), []);
  assert.deepEqual(parseTodos(null), []);
});

test("preserves todo order", () => {
  assert.deepEqual(parseTodos(JSON.stringify([
    { title: "First" },
    { title: "Second" },
    { title: "Third" }
  ])).map((todo) => todo.title), ["First", "Second", "Third"]);
});

test("sorts completed todos after open todos while preserving group order", () => {
  assert.deepEqual(parseTodos(JSON.stringify([
    { title: "Done first", completed: true },
    { title: "Open first", completed: false },
    { title: "Done second", completed: true },
    { title: "Open second", completed: false }
  ])).map((todo) => todo.title), [
    "Open first", "Open second", "Done first", "Done second"
  ]);
});
