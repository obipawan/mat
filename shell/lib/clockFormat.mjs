// Clock patterns for the bar clock (docs/lld/02-contracts.md §2.12; spec 02-bar-widgets.md §8 ClockWidget.qml).

// Qt date/time codes, longest first; quoted text is literal (same list as showcase/index.html QT_TOKENS).
const QT_CODES = /dddd|ddd|dd|d|MMMM|MMM|MM|M|yyyy|yy|HH|H|hh|h|mm|m|ss|s|AP|ap/;

function unquoted(pattern) {
  return pattern.replace(/'[^']*'/g, "");
}

export function clockPattern(opt, systemTwelveHour) {
  const twelveHour = opt.hourCycle === "12h" || (opt.hourCycle === "system" && systemTwelveHour);
  const time = (twelveHour ? "h:mm" : "HH:mm") + (opt.showSeconds ? ":ss" : "") + (twelveHour ? " AP" : "");
  const presets = { time, weekdayTime: "ddd  " + time, dateTime: "ddd d MMM  " + time, fullDate: "dddd d MMMM  " + time };
  const pattern = opt.preset === "custom" ? opt.customFormat : presets[opt.preset] || presets.dateTime;
  return { pattern, timePattern: time, twelveHour, needsSeconds: /s/.test(unquoted(pattern)) };
}

export function verticalPatterns(opt, twelveHour) {
  return [twelveHour ? "h" : "HH", "mm"].concat(opt.showSeconds ? ["ss"] : []);
}

export function qtPatternError(pattern) {
  if (!pattern.trim()) return "Enter a pattern";
  if ((pattern.match(/'/g) || []).length % 2) return "Close the quoted text with '";
  if (!QT_CODES.test(unquoted(pattern))) return "Add at least one date or time code, e.g. HH:mm";
  return "";
}
