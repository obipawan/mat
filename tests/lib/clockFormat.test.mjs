import { test } from "node:test";
import assert from "node:assert/strict";
import { clockPattern, verticalPatterns, qtPatternError } from "../../shell/lib/clockFormat.mjs";

test("clockPattern: presets build the date and time parts", () => {
  assert.equal(clockPattern({ preset: "dateTime", hourCycle: "24h", showSeconds: false }, false).pattern, "ddd d MMM  HH:mm");
  const t = clockPattern({ preset: "time", hourCycle: "12h", showSeconds: true }, false);
  assert.equal(t.pattern, "h:mm:ss AP"); assert.equal(t.needsSeconds, true);
});

test("clockPattern: system hour cycle follows the system", () => {
  assert.equal(clockPattern({ preset: "time", hourCycle: "system", showSeconds: false }, true).twelveHour, true);
});

test("clockPattern: custom patterns need seconds only for an unquoted s", () => {
  assert.equal(clockPattern({ preset: "custom", customFormat: "dddd 'at' HH:mm" }, false).needsSeconds, false);
  assert.equal(clockPattern({ preset: "custom", customFormat: "HH:mm:ss" }, false).needsSeconds, true);
  assert.equal(clockPattern({ preset: "custom", customFormat: "'s' HH" }, false).needsSeconds, false);
});

test("verticalPatterns: stacked hours, minutes, seconds", () => {
  assert.deepEqual(verticalPatterns({ showSeconds: true }, false), ["HH", "mm", "ss"]);
});

test("qtPatternError: empty, unclosed quote, no codes, valid", () => {
  assert.equal(qtPatternError(""), "Enter a pattern");
  assert.equal(qtPatternError("'oops"), "Close the quoted text with '");
  assert.equal(qtPatternError("'only text'"), "Add at least one date or time code, e.g. HH:mm");
  assert.equal(qtPatternError("HH:mm"), "");
});

// Contract details beyond the card (02-contracts.md §2.12)

test("clockPattern: weekdayTime and fullDate; timePattern is the time part, even under custom", () => {
  const o = { hourCycle: "24h", showSeconds: false, customFormat: "yyyy" };
  assert.equal(clockPattern({ ...o, preset: "weekdayTime" }, false).pattern, "ddd  HH:mm");
  assert.equal(clockPattern({ ...o, preset: "fullDate" }, false).pattern, "dddd d MMMM  HH:mm");
  assert.equal(clockPattern({ ...o, preset: "custom" }, false).timePattern, "HH:mm");
});

test("clockPattern: a hidden showSeconds under custom does not need seconds", () => {
  assert.equal(clockPattern({ preset: "custom", customFormat: "HH:mm", showSeconds: true, hourCycle: "24h" }, false).needsSeconds, false);
});

test("verticalPatterns: 12-hour without seconds; qtPatternError: whitespace only", () => {
  assert.deepEqual(verticalPatterns({ showSeconds: false }, true), ["h", "mm"]);
  assert.equal(qtPatternError("   "), "Enter a pattern");
});
