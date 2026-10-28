// Where a popover card sits and the point it grows from (docs/lld/02-contracts.md §2.9; spec primitives/04 §1).
import { clamp } from "./util.mjs";

export function placePopover({ edge, origin, card, screen, insets, gap }) {
  const cx = origin.x + origin.width / 2;
  const cy = origin.y + origin.height / 2;
  const alongX = () => Math.round(clamp(cx - card.width / 2, insets.left + gap, screen.width - insets.right - gap - card.width));
  const alongY = () => Math.round(clamp(cy - card.height / 2, insets.top + gap, screen.height - insets.bottom - gap - card.height));
  const facingX = (x) => clamp(cx - x, 0, card.width);
  const facingY = (y) => clamp(cy - y, 0, card.height);
  if (edge === "top") {
    const x = alongX();
    return { x, y: insets.top + gap, originX: facingX(x), originY: 0 };
  }
  if (edge === "bottom") {
    const x = alongX();
    return { x, y: screen.height - insets.bottom - gap - card.height, originX: facingX(x), originY: card.height };
  }
  if (edge === "left") {
    const y = alongY();
    return { x: insets.left + gap, y, originX: 0, originY: facingY(y) };
  }
  if (edge === "right") {
    const y = alongY();
    return { x: screen.width - insets.right - gap - card.width, y, originX: card.width, originY: facingY(y) };
  }
  return { x: screen.width - insets.right - gap - card.width, y: insets.top + gap, originX: card.width, originY: 0 };
}
