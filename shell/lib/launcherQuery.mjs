// Launcher query parsing and app ranking (docs/lld/02-contracts.md §2.12; spec 08-app-and-command-launcher.md).

export function parseQuery(text) {
  const s = text.replace(/^\s+/, "");
  for (const mode of ["win", "clip"]) {
    if (s === mode || s.startsWith(mode + " ")) return { mode, term: s.slice(mode.length).trim() };
  }
  const sigils = { "=": "calc", ">": "cmd", ":": "emoji" };
  if (s[0] in sigils) return { mode: sigils[s[0]], term: s.slice(1).trim() };
  return { mode: "apps", term: s.trim() };
}

const WORD_BREAK = " -_.";

export function fuzzyScore(term, text) {
  const t = term.toLowerCase();
  const x = text.toLowerCase();
  if (!t) return 0;
  if (x.startsWith(t)) return Math.max(1, 300 - text.length);
  for (let i = 1; i < x.length; i++) {
    if (WORD_BREAK.includes(x[i - 1]) && x.startsWith(t, i)) return Math.max(1, 200 - text.length);
  }
  let first = -1;
  let at = -1;
  for (const ch of t) {
    at = x.indexOf(ch, at + 1);
    if (at < 0) return 0;
    if (first < 0) first = at;
  }
  return Math.max(1, 100 - (at - first + 1 - t.length));
}

// Case-insensitive code-point order: QML's localeCompare follows LC_COLLATE, and `<` compares UTF-16 units.
function byName(a, b) {
  const x = Array.from(a.toLowerCase());
  const y = Array.from(b.toLowerCase());
  for (let i = 0; i < Math.min(x.length, y.length); i++) {
    const d = x[i].codePointAt(0) - y[i].codePointAt(0);
    if (d) return d;
  }
  return x.length - y.length;
}

export function rankApps(term, apps, usage, limit = 8) {
  const used = (a) => usage[a.id] || 0;
  const fields = (a) => [a.name, a.genericName || ""].concat(Array.from(a.keywords || [])).filter((f) => typeof f === "string");
  const score = (a) => Math.max(0, ...fields(a).map((f) => fuzzyScore(term, f)));
  const rows = apps.map((app, i) => ({ app, i, score: term ? score(app) : 0 })).filter((r) => !term || r.score > 0);
  rows.sort((a, b) => b.score - a.score || used(b.app) - used(a.app) || byName(a.app.name, b.app.name) || a.i - b.i);
  return rows.slice(0, limit).map((r) => r.app);
}
