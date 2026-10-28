import { test } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { userDirs, rebaseMatugenConfig } from "../../shell/lib/paths.mjs";

test("userDirs: HOME alone gives the XDG defaults", () => {
  assert.deepEqual(userDirs({ HOME: "/home/u" }), {
    homeDir: "/home/u", configDir: "/home/u/.config/mat-shell", cacheDir: "/home/u/.cache/mat-shell", warnings: [],
  });
});

test("userDirs: absolute XDG variables win; trailing slashes are dropped", () => {
  const d = userDirs({ HOME: "/home/u/", XDG_CONFIG_HOME: "/x/cfg/", XDG_CACHE_HOME: "/x/cache" });
  assert.equal(d.homeDir, "/home/u");
  assert.equal(d.configDir, "/x/cfg/mat-shell");
  assert.equal(d.cacheDir, "/x/cache/mat-shell");
  assert.deepEqual(d.warnings, []);
});

test("userDirs: empty, unset (null/undefined from QML) and relative XDG values fall back", () => {
  assert.equal(userDirs({ HOME: "/home/u", XDG_CONFIG_HOME: "" }).configDir, "/home/u/.config/mat-shell");
  assert.equal(userDirs({ HOME: "/home/u", XDG_CONFIG_HOME: null, XDG_CACHE_HOME: undefined }).cacheDir, "/home/u/.cache/mat-shell");
  const rel = userDirs({ HOME: "/home/u", XDG_CONFIG_HOME: "rel/cfg" });
  assert.equal(rel.configDir, "/home/u/.config/mat-shell");
  assert.deepEqual(rel.warnings, ["XDG_CONFIG_HOME is not an absolute path; using /home/u/.config"]);
});

test("userDirs: a missing or relative HOME warns and never throws", () => {
  assert.deepEqual(userDirs({}), {
    homeDir: "", configDir: "/.config/mat-shell", cacheDir: "/.cache/mat-shell", warnings: ["HOME is not set to an absolute path"],
  });
  assert.deepEqual(userDirs(null).warnings, ["HOME is not set to an absolute path"]);
  assert.equal(userDirs({ HOME: "u" }).homeDir, "");
});

test("userDirs: HOME=/ joins without a double slash", () => {
  const d = userDirs({ HOME: "/" });
  assert.equal(d.homeDir, "");
  assert.equal(d.configDir, "/.config/mat-shell");
  assert.deepEqual(d.warnings, []);
});

test("rebaseMatugenConfig: replaces every ~/.config/mat-shell and nothing else", () => {
  const text = 'a = "~/.config/mat-shell/x"\nb = "~/.config/mat-shell/y" # ~/.config/other\n';
  assert.equal(rebaseMatugenConfig(text, "/c/mat-shell"), 'a = "/c/mat-shell/x"\nb = "/c/mat-shell/y" # ~/.config/other\n');
});

test("rebaseMatugenConfig: quotes, backslashes and control characters stay inside the TOML string", () => {
  assert.equal(rebaseMatugenConfig('p = "~/.config/mat-shell/t"', '/a"b\\c\nd'), 'p = "/a\\"b\\\\c\\u000Ad/t"');
});

test("rebaseMatugenConfig: the shipped config.toml points only at configDir", () => {
  const shipped = readFileSync(new URL("../../shell/assets/matugen/config.toml", import.meta.url), "utf8");
  const out = rebaseMatugenConfig(shipped, "/home/u/.config/mat-shell");
  assert.ok(!out.includes("~/"));
  assert.match(out, /^input_path = "\/home\/u\/\.config\/mat-shell\/matugen\/theme\.json\.tpl"$/m);
  assert.match(out, /^output_path = "\/home\/u\/\.config\/mat-shell\/theme\.json"$/m);
});
