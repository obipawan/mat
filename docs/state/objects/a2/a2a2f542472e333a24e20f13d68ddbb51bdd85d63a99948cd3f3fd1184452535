// Wheel and touchpad accumulation into whole steps (docs/lld/02-contracts.md §2.10; spec foundations/04 §3).

export function wheelStep(acc, ev, opts) {
  const pixels = ev.pixelDeltaY !== 0;
  const step = pixels ? opts.stepPixels : opts.stepAngle;
  let delta = pixels ? ev.pixelDeltaY : ev.angleDeltaY;
  if (opts.physical && ev.inverted) delta = -delta;
  const total = acc + delta;
  const steps = Math.trunc(total / step) || 0; // `|| 0` turns -0 into 0
  return { acc: total - steps * step, steps };
}
