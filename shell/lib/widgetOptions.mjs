// Widget options: resolve, diff, migrate and list editing (docs/lld/02-contracts.md §2.4; spec 02-bar-widgets.md §1.2–§1.4).
import { clamp, clone, deepEqual } from "./util.mjs";
import { WIDGET_OPTIONS } from "./generated/widgetOptionsSchema.mjs";

function isObject(v) {
  return typeof v === "object" && v !== null && !Array.isArray(v);
}

function own(obj, key) {
  return Object.prototype.hasOwnProperty.call(obj, key);
}

// User keys are written as own data properties: `obj[key] = v` would treat "__proto__" as the prototype.
function setOwn(obj, key, value) {
  Object.defineProperty(obj, key, { value, writable: true, enumerable: true, configurable: true });
}

export function hasOptions(type) {
  return optionsSchema(type).length > 0;
}

export function optionsSchema(type) {
  return own(WIDGET_OPTIONS, type) ? WIDGET_OPTIONS[type] : [];
}

export function fieldApplies(field, orientation) {
  return !field.orientations || field.orientations === "both" || field.orientations === orientation;
}

// Turn a stored value into a valid one for the field; anything unusable falls back to the default.
function sanitize(f, v) {
  switch (f.kind) {
    case "number":
      return typeof v === "number" && isFinite(v) ? clamp(v, f.min, f.max) : f.default;
    case "choice":
      return f.choices.some((c) => c.value === v) ? v : f.default;
    case "toggle":
      return typeof v === "boolean" ? v : f.default;
    case "text":
    case "format":
      if (typeof v !== "string") return f.default;
      return f.maxLength ? v.slice(0, f.maxLength) : v;
    case "multiChoice": {
      const allowed = f.choices.map((c) => c.value);
      const list = (Array.isArray(v) ? v : []).filter((x, i, a) => allowed.includes(x) && a.indexOf(x) === i);
      const cut = list.slice(0, f.max || allowed.length);
      return cut.length < (f.min || 0) ? clone(f.default) : cut;
    }
    case "appList":
      return Array.isArray(v) ? v.slice() : clone(f.default);
    default:
      return f.default;
  }
}

export function resolve(type, options, orientation) {
  const stored = isObject(options) ? options : {};
  const out = {};
  for (const f of optionsSchema(type)) {
    const v = own(stored, f.key) && fieldApplies(f, orientation) ? stored[f.key] : clone(f.default);
    out[f.key] = sanitize(f, v);
  }
  return out;
}

export function diffFromDefaults(type, options) {
  const out = {};
  if (!isObject(options)) return out;
  for (const k of Object.keys(options)) {
    const f = optionsSchema(type).find((x) => x.key === k);
    if (!f || !deepEqual(options[k], f.default)) setOwn(out, k, clone(options[k]));
  }
  return out;
}

// Rules mirror m3-tokens.json modes.bars.widgetOptionMigrations (the tests replay that data).
export function migrate(type, options) {
  if (options === undefined || options === null) return { options: {}, warnings: [] };
  if (!isObject(options)) return { options: {}, warnings: [type + ": options must be an object; using defaults"] };
  const o = clone(options); // a JSON copy keeps a "__proto__" key as an own key
  if (type === "clock") {
    if (typeof o.format === "string") {
      o.preset = "custom";
      o.customFormat = o.format;
    } else if (o.showDate === false && !own(o, "preset")) {
      o.preset = "time";
    }
    delete o.format;
    delete o.showDate;
  }
  return { options: diffFromDefaults(type, o), warnings: [] };
}

export function isFieldVisible(field, resolved) {
  const w = field.visibleWhen;
  if (!w) return true;
  const v = resolved[w.key];
  if ("equals" in w) return v === w.equals;
  if ("notEquals" in w) return v !== w.notEquals;
  if ("includes" in w) return Array.isArray(v) && v.includes(w.includes);
  return true;
}

export function toggleListItem(field, list, value) {
  const i = list.indexOf(value);
  const next = i >= 0 ? list.filter((_, j) => j !== i) : list.concat([value]);
  if (next.length < (field.min || 0) || (field.max && next.length > field.max)) return null;
  return next;
}

export function moveListItem(list, from, to) {
  const next = list.slice();
  if (from < 0 || from >= list.length || to < 0 || to >= list.length || from === to) return next;
  next.splice(to, 0, next.splice(from, 1)[0]);
  return next;
}

export function limitNote(field, list) {
  if (field.kind !== "multiChoice") return "";
  if (field.max && list.length >= field.max) return "Up to " + field.max + " items · drag to reorder";
  if (field.min && list.length <= field.min) return "At least " + field.min + " item" + (field.min > 1 ? "s" : "") + " · drag to reorder";
  return "Drag to reorder; order on the bar follows this list";
}
