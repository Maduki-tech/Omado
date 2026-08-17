const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

const root = path.resolve(__dirname, "..");
const manifest = JSON.parse(fs.readFileSync(path.join(root, "manifest.json"), "utf8"));

test("manifest identifies Omado as a bar widget", () => {
  assert.equal(manifest.schemaVersion, 1);
  assert.equal(manifest.id, "maduki-tech.omado");
  assert.equal(manifest.name, "Omado");
  assert.deepEqual(manifest.kinds, ["bar-widget"]);
});

test("manifest bar widget entry point exists", () => {
  assert.equal(manifest.entryPoints.barWidget, "BarWidget.qml");
  assert.equal(fs.existsSync(path.join(root, manifest.entryPoints.barWidget)), true);
});

test("manifest declares required bar widget metadata", () => {
  assert.equal(manifest.barWidget.displayName, "Omado");
  assert.equal(manifest.barWidget.category, "Productivity");
  assert.equal(manifest.barWidget.allowMultiple, false);
});
