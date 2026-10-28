// /proc parsers for the system monitor (docs/lld/02-contracts.md §2.12; spec interactions/03 §2.3).

export function parseProcStat(text) {
  const line = text.split("\n").find((l) => l.startsWith("cpu "));
  if (!line) return { idle: 0, total: 0 };
  const f = line.trim().split(/\s+/).slice(1).map(Number).filter((n) => isFinite(n));
  return { idle: (f[3] || 0) + (f[4] || 0), total: f.reduce((sum, n) => sum + n, 0) };
}

export function cpuPercent(prev, cur) {
  const dt = cur.total - prev.total;
  if (dt <= 0) return 0;
  return Math.round(100 * (1 - (cur.idle - prev.idle) / dt));
}

export function parseMeminfo(text) {
  const field = (name) => {
    const m = text.match(new RegExp("^" + name + ":\\s+(\\d+)", "m"));
    return m ? Number(m[1]) : 0;
  };
  const totalKb = field("MemTotal");
  const availableKb = field("MemAvailable");
  return { totalKb, availableKb, usedPercent: totalKb ? Math.round((100 * (totalKb - availableKb)) / totalKb) : 0 };
}
