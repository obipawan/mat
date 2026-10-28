// The bar widget catalog (docs/lld/02-contracts.md §2.3; labels and descriptions from 02-bar-widgets.md §1.1).
import { pascalCase } from "./util.mjs";
import { WIDGET_TYPES } from "./generated/barPresets.mjs";
import { WIDGET_OPTIONS } from "./generated/widgetOptionsSchema.mjs";

// overflowPriority: higher numbers collapse first (C10); null = never hidden.
const ENTRIES = {
  launcher:       { label: "Launcher", icon: "apps", overflowPriority: null, security: false, description: "App/command launcher trigger" },
  search:         { label: "Search", icon: "search", overflowPriority: 2, security: false, description: "Search field pill (width: 148px)" },
  workspaces:     { label: "Workspaces", icon: "view_week", overflowPriority: null, security: false, description: "Morphing workspace strip (§3.1)" },
  submap:         { label: "Keybinding mode", icon: "open_with", overflowPriority: null, security: false, description: "Transient compositor submap badge (RESIZE)" },
  windowTitle:    { label: "Window title", icon: "web_asset", overflowPriority: 1, security: false, description: "Focused app icon + title + tiling flags (floating: app menu)" },
  media:          { label: "Media", icon: "graphic_eq", overflowPriority: 3, security: false, description: "MPRIS title pill / art well with progress ring" },
  clock:          { label: "Clock & calendar", icon: "schedule", overflowPriority: null, security: false, description: "Date and time pill (tnum)" },
  controlCenter:  { label: "Control center", icon: "toggle_on", overflowPriority: null, security: false, description: "Quick-settings capsule (Wi-Fi, BT, volume, battery glyphs)" },
  notifications:  { label: "Notifications", icon: "notifications", overflowPriority: null, security: false, description: "Bell with unread count; middle-click toggles Do Not Disturb" },
  tray:           { label: "System tray", icon: "more_horiz", overflowPriority: 4, security: false, description: "StatusNotifier items" },
  privacy:        { label: "Privacy indicator", icon: "mic", overflowPriority: null, security: true, description: "Mic/camera/screen-share pill (transient)" },
  recording:      { label: "Recording indicator", icon: "radio_button_checked", overflowPriority: null, security: true, description: "Active recording timer pill (transient)" },
  telemetry:      { label: "System monitor", icon: "memory", overflowPriority: 5, security: false, description: "CPU / RAM / GPU / disk / network pill (tnum)" },
  keyboardLayout: { label: "Keyboard layout", icon: "keyboard", overflowPriority: 4, security: false, description: "Current layout code (EN)" },
  power:          { label: "Power", icon: "power_settings_new", overflowPriority: null, security: false, description: "Power button" },
  apps:           { label: "Apps (dock / taskbar)", icon: "grid_view", overflowPriority: null, security: false, description: "Pinned + running app wells with indicators (§3.2)" },
  widgetPeek:     { label: "Desktop widgets", icon: "widgets", overflowPriority: 3, security: false, description: "scallop_12 Widget Peek trigger (only when desktop widgets are enabled)" },
  settings:       { label: "Settings", icon: "settings", overflowPriority: 4, security: false, description: "Gear button" },
  separator:      { label: "Separator", icon: "more_vert", overflowPriority: null, security: false, description: "1px divider between groups" },
  spacer:         { label: "Spacer", icon: "space_bar", overflowPriority: null, security: false, description: "Gap inside a section" },
};

export const CATALOG = WIDGET_TYPES.map((type) => ({
  type,
  label: ENTRIES[type].label,
  icon: ENTRIES[type].icon,
  description: ENTRIES[type].description,
  customisable: type in WIDGET_OPTIONS,
  overflowPriority: ENTRIES[type].overflowPriority,
  security: ENTRIES[type].security,
}));

export function catalogEntry(type) {
  return CATALOG.find((e) => e.type === type) || null;
}

export function sourceFile(type) {
  return "widgets/" + pascalCase(type) + "Widget.qml";
}
