import { test } from "node:test";
import assert from "node:assert/strict";
import {
  POPOVERS, MODALS, LAUNCHER_MODES, INITIAL, securityModalActive, togglePopover, closePopover, toggleModal, openModal,
  closeModal, openLauncherMode, lock, unlock, openSettings, focusBar, escape,
} from "../../shell/lib/shellReducer.mjs";

const S = o => ({ ...INITIAL, ...o });
const pk = S({ activeModal: "polkit" });

test("togglePopover: opens, closes the same one, keeps it when the trigger differs, clears modals", () => {
  assert.equal(togglePopover(INITIAL, "calendar", true).activePopover, "calendar");
  assert.equal(togglePopover(S({ activePopover: "calendar" }), "calendar", true).activePopover, "");
  assert.equal(togglePopover(S({ activePopover: "calendar" }), "calendar", false).activePopover, "calendar");
  assert.equal(togglePopover(S({ activeModal: "launcher" }), "media", true).activeModal, "");
});

test("togglePopover: unknown names and a locked session change nothing", () => {
  assert.deepEqual(togglePopover(INITIAL, "bogus", true), INITIAL);
  assert.deepEqual(togglePopover(S({ sessionLocked: true }), "media", true), S({ sessionLocked: true }));
});

test("polkit: blocks popovers and modal toggles; preempts other modals; only closes by polkit", () => {
  assert.deepEqual(togglePopover(pk, "media", true), pk);
  assert.deepEqual(toggleModal(pk, "launcher"), pk);
  assert.deepEqual(toggleModal(pk, "polkit"), pk);
  assert.equal(openModal(S({ activeModal: "launcher" }), "polkit").activeModal, "polkit");
  assert.deepEqual(closeModal(pk), pk);
  assert.equal(closeModal(pk, true).activeModal, "");
});

test("toggleModal: the open modal closes", () => {
  assert.equal(toggleModal(S({ activeModal: "power" }), "power").activeModal, "");
});

test("openLauncherMode: opens the launcher in that mode; an invalid mode → apps", () => {
  assert.deepEqual(openLauncherMode(INITIAL, "emoji"), S({ activeModal: "launcher", launcherMode: "emoji" }));
  assert.equal(openLauncherMode(INITIAL, "bogus").launcherMode, "apps");
});

test("lock: clears every lane and locks", () => {
  assert.deepEqual(lock(S({ activePopover: "media", activeModal: "overview", barFocusActive: true })), S({ sessionLocked: true }));
});

test("openSettings: refused while locked; otherwise clears lanes and emits", () => {
  assert.equal(openSettings(S({ sessionLocked: true })).emit, false);
  assert.deepEqual(openSettings(S({ activePopover: "media" })), { state: INITIAL, emit: true });
});

test("focusBar: enters bar focus and closes the popover", () => {
  assert.equal(focusBar(S({ activePopover: "media" })).barFocusActive, true);
  assert.equal(focusBar(S({ activePopover: "media" })).activePopover, "");
});

test("escape: inline first, then polkit, then open surfaces, else none", () => {
  assert.deepEqual(escape(S({ activePopover: "media" }), 1), { state: S({ activePopover: "media" }), consumed: "inline" });
  assert.equal(escape(pk, 0).consumed, "polkit");
  assert.deepEqual(escape(S({ activePopover: "media" }), 0), { state: INITIAL, consumed: "surface" });
  assert.equal(escape(INITIAL, 0).consumed, "none");
});

test("Review Focus 5: a burst of conflicting triggers stays consistent", () => {
  let s = INITIAL;
  for (const step of [x => togglePopover(x, "media", true), x => toggleModal(x, "launcher"), x => togglePopover(x, "calendar", true),
                      x => openModal(x, "polkit"), x => toggleModal(x, "power"), x => closeModal(x, true), x => lock(x)])
    s = step(s);
  assert.deepEqual(s, S({ sessionLocked: true }));
});

test("the reducer never mutates its input", () => {
  Object.freeze(INITIAL); assert.doesNotThrow(() => { togglePopover(INITIAL, "media", true); lock(INITIAL); escape(INITIAL, 0); });
});

// Contract details beyond the card (02-contracts.md §2.8)

test("lane lists match 01-architecture.md §5.1", () => {
  assert.deepEqual(POPOVERS, ["control_center", "notifications", "calendar", "media"]);
  assert.deepEqual(MODALS, ["launcher", "overview", "power", "polkit", "capture", "theme_studio", "widget_peek"]);
  assert.deepEqual(LAUNCHER_MODES, ["apps", "win", "calc", "clip", "cmd", "emoji"]);
});

test("securityModalActive, closePopover and unlock", () => {
  assert.equal(securityModalActive(pk), true);
  assert.equal(securityModalActive(INITIAL), false);
  assert.equal(closePopover(S({ activePopover: "media" })).activePopover, "");
  assert.equal(unlock(S({ sessionLocked: true })).sessionLocked, false);
});

test("modals: a locked session or an unknown name changes nothing; polkit still opens over another modal only when unlocked", () => {
  assert.deepEqual(toggleModal(S({ sessionLocked: true }), "power"), S({ sessionLocked: true }));
  assert.deepEqual(openModal(INITIAL, "bogus"), INITIAL);
  assert.deepEqual(openModal(pk, "launcher"), pk);
  assert.deepEqual(openLauncherMode(pk, "emoji"), pk);
});

test("focusBar and openSettings are refused while polkit is active", () => {
  assert.deepEqual(focusBar(pk), pk);
  assert.deepEqual(openSettings(pk), { state: pk, emit: false });
});
