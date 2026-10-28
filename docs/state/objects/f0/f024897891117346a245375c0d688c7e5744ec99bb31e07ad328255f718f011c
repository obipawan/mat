// Bar overflow planner (docs/lld/02-contracts.md §2.7; spec 02-bar-widgets.md §2.1; order per C10).

// Item ids can be widget types from config.json, so steps are own keys ("__proto__" is an ordinary id).
function setOwn(obj, key, value) {
  Object.defineProperty(obj, key, { value, writable: true, enumerable: true, configurable: true });
}

function used(items, steps, gap) {
  const widths = items.map((it) => it.widths[steps[it.id]]);
  const visible = widths.filter((w) => w > 0).length;
  return widths.reduce((sum, w) => sum + w, 0) + gap * Math.max(visible - 1, 0);
}

export function planOverflow(items, available, gap) {
  const steps = {};
  for (const it of items) setOwn(steps, it.id, 0);
  while (used(items, steps, gap) > available) {
    let pick = null;
    for (const it of items) {
      // Highest priority number first; `>=` lets a later item win a tie.
      if (it.priority !== null && steps[it.id] + 1 < it.widths.length && (pick === null || it.priority >= pick.priority)) pick = it;
    }
    if (pick === null) break;
    setOwn(steps, pick.id, steps[pick.id] + 1);
  }
  return { steps, hidden: items.filter((it) => it.widths[steps[it.id]] === 0).map((it) => it.id) };
}
