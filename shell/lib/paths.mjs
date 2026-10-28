// User directories and seeded file text (docs/lld/02-contracts.md §2.13; docs/lld/07-distribution.md §2-§3).

// Values from Quickshell.env() are null or undefined when a variable is unset.
function absolute(v) {
  return typeof v === "string" && v.startsWith("/") ? v.replace(/\/+$/, "") : null;
}

function base(name, value, fallback, warnings) {
  const dir = absolute(value);
  if (dir !== null) return dir;
  if (typeof value === "string" && value !== "") warnings.push(`${name} is not an absolute path; using ${fallback}`);
  return fallback;
}

export function userDirs(env) {
  const e = env || {};
  const warnings = [];
  let homeDir = absolute(e.HOME);
  if (homeDir === null) {
    warnings.push("HOME is not set to an absolute path");
    homeDir = "";
  }
  const configHome = base("XDG_CONFIG_HOME", e.XDG_CONFIG_HOME, homeDir + "/.config", warnings);
  const cacheHome = base("XDG_CACHE_HOME", e.XDG_CACHE_HOME, homeDir + "/.cache", warnings);
  return { homeDir, configDir: configHome + "/mat-shell", cacheDir: cacheHome + "/mat-shell", warnings };
}

// TOML basic-string escape: backslash, quote and control characters.
function tomlEscape(s) {
  let out = "";
  for (const ch of s) {
    const c = ch.codePointAt(0);
    if (ch === "\\" || ch === "\"") out += "\\" + ch;
    else if (c < 0x20 || c === 0x7f) out += "\\u" + c.toString(16).toUpperCase().padStart(4, "0");
    else out += ch;
  }
  return out;
}

export function rebaseMatugenConfig(text, configDir) {
  return String(text).split("~/.config/mat-shell").join(tomlEscape(String(configDir)));
}
