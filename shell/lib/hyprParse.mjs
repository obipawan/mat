// Hyprland client parsing and the dodge-visibility overlap test (docs/lld/02-contracts.md §2.12; spec 01-bar-system.md §5).

export function parseClients(json) {
  if (!Array.isArray(json)) return [];
  return json
    .filter((c) => typeof c === "object" && c !== null)
    .map((c) => ({
      address: c.address,
      title: c.title,
      appId: c.class,
      workspaceId: c.workspace ? c.workspace.id : -1,
      monitor: c.monitor,
      floating: c.floating === true,
      fullscreen: c.fullscreen !== 0 && c.fullscreen !== false && c.fullscreen !== undefined,
      x: Array.isArray(c.at) ? c.at[0] : 0,
      y: Array.isArray(c.at) ? c.at[1] : 0,
      width: Array.isArray(c.size) ? c.size[0] : 0,
      height: Array.isArray(c.size) ? c.size[1] : 0,
    }));
}

export function windowsOverlap(clients, rect, workspaceId) {
  return clients.some((c) => !c.floating && c.workspaceId === workspaceId &&
    c.x < rect.x + rect.width && c.x + c.width > rect.x && c.y < rect.y + rect.height && c.y + c.height > rect.y);
}
