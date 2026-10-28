import { test } from "node:test";
import assert from "node:assert/strict";
import { parseWttr, isStale, weatherIcon } from "../../shell/lib/weather.mjs";

test("parseWttr: current conditions from wttr j1", () => {
  const j1 = { current_condition: [{ temp_C: "21", FeelsLikeC: "20", weatherCode: "116", weatherDesc: [{ value: "Partly cloudy" }], humidity: "40", windspeedKmph: "11" }],
    weather: [{ hourly: [{ time: "0", tempC: "18", weatherCode: "113" }, { time: "300", tempC: "17", weatherCode: "113" }] }] };
  const wx = parseWttr(j1, 1000);
  assert.equal(wx.tempC, 21); assert.equal(wx.code, 116); assert.equal(wx.description, "Partly cloudy"); assert.equal(wx.fetchedAt, 1000);
});

test("parseWttr: malformed → null", () => {
  assert.equal(parseWttr({}, 1), null);
});

test("isStale: older than 30 minutes", () => {
  assert.equal(isStale(0, 1800001), true); assert.equal(isStale(0, 1800000), false);
});

test("weatherIcon: code groups, day and night", () => {
  assert.equal(weatherIcon(113, false), "sunny"); assert.equal(weatherIcon(113, true), "clear_night");
  assert.equal(weatherIcon(389, false), "thunderstorm"); assert.equal(weatherIcon(230, false), "weather_snowy"); assert.equal(weatherIcon(296, false), "rainy");
});

// Contract details beyond the card (02-contracts.md §2.12)

const at = (hour) => new Date(2026, 9, 27, hour, 30).getTime();
const slots = (temps) => temps.map((t, i) => ({ time: String(i * 300), tempC: String(t), weatherCode: "113" }));

test("parseWttr: numbers parsed; hourly starts at the current local hour and spans into tomorrow, at most 6", () => {
  const j = { current_condition: [{ temp_C: "21", FeelsLikeC: "20", weatherCode: "116", weatherDesc: [{ value: "x" }], humidity: "40", windspeedKmph: "11" }],
    weather: [{ hourly: slots([10, 11, 12, 13, 14, 15, 16, 17]) }, { hourly: slots([20, 21, 22, 23, 24, 25, 26, 27]) }] };
  const wx = parseWttr(j, at(13));
  assert.equal(wx.feelsLikeC, 20); assert.equal(wx.humidity, 40); assert.equal(wx.windKph, 11);
  assert.deepEqual(wx.hourly.map(h => [h.day, h.hour, h.tempC]), [[0, 15, 15], [0, 18, 16], [0, 21, 17], [1, 0, 20], [1, 3, 21], [1, 6, 22]]);
  assert.equal(parseWttr(j, at(23)).hourly[0].day, 1);
});

test("parseWttr: a non-numeric temperature → null", () => {
  assert.equal(parseWttr({ current_condition: [{ temp_C: "warm" }] }, 1), null);
});

test("weatherIcon: partly cloudy, cloud, fog, and the snow range", () => {
  assert.equal(weatherIcon(116, true), "partly_cloudy_night");
  assert.equal(weatherIcon(122, false), "cloud");
  assert.equal(weatherIcon(248, false), "foggy");
  assert.equal(weatherIcon(329, false), "weather_snowy");
  assert.equal(weatherIcon(395, true), "thunderstorm");
});

// Checkpoint 10 review fixes

test("parseWttr: hourly slots that are not objects are skipped", () => {
  const wx = parseWttr({ current_condition: [{ temp_C: "1" }], weather: [{ hourly: [null, 7, { time: "2100", tempC: "3", weatherCode: "113" }] }] }, at(0));
  assert.deepEqual(wx.hourly.map(h => h.tempC), [3]);
});
