pragma Singleton
import QtQuick
import Quickshell

/**
 * MotionTokens.qml — Material 3 Expressive Spring Physics & Bezier Tokens
 *
 * Rule:
 * - Spatial properties (x, y, width, height, scale, radius) use SPATIAL springs (allow slight bounce).
 * - Visual effect properties (color, opacity, blur, stateLayer alpha) use EFFECTS curves (critically damped, zero overshoot).
 *
 * Reduced Motion (Tokens.reducedMotion):
 * - Spatial Behaviors bind `enabled: Tokens.motion.spatialMotionEnabled`, so geometry jumps to its target.
 * - Effects keep a short `reducedMotionFadeMs` crossfade so state changes never feel like glitches.
 * - Infinite or decorative loops (polygon rotation, seekbar wave, pulses, bounces) bind `running: Tokens.motion.decorativeMotionEnabled && ...`.
 */
Singleton {
    id: root

    property bool reducedMotion: false
    property bool expressiveSprings: true // Settings → Animations → Expressive bounce; false keeps motion but removes overshoot

    readonly property int reducedMotionFadeMs: 100
    readonly property bool spatialMotionEnabled: !reducedMotion
    readonly property bool decorativeMotionEnabled: !reducedMotion
    readonly property bool overshootEnabled: expressiveSprings && !reducedMotion

    // M3 Expressive Spatial Springs (for SpringAnimation)
    readonly property QtObject springFastSpatial: QtObject {
        readonly property real damping: root.overshootEnabled ? 0.65 : 1.0
        readonly property real spring: 700.0 / 100.0   // QtQuick SpringAnimation spring factor (7.0)
        readonly property real epsilon: 0.005
        readonly property int fallbackDurationMs: root.reducedMotion ? 0 : 250
    }

    readonly property QtObject springDefaultSpatial: QtObject {
        readonly property real damping: root.overshootEnabled ? 0.72 : 1.0
        readonly property real spring: 450.0 / 100.0   // QtQuick SpringAnimation spring factor (4.5)
        readonly property real epsilon: 0.005
        readonly property int fallbackDurationMs: root.reducedMotion ? 0 : 350
    }

    readonly property QtObject springSlowSpatial: QtObject {
        readonly property real damping: root.overshootEnabled ? 0.78 : 1.0
        readonly property real spring: 260.0 / 100.0   // QtQuick SpringAnimation spring factor (2.6)
        readonly property real epsilon: 0.005
        readonly property int fallbackDurationMs: root.reducedMotion ? 0 : 500
    }

    // M3 Expressive Effects Springs / Critically Damped Curves (zero overshoot)
    readonly property QtObject springFastEffects: QtObject {
        readonly property real damping: 1.0
        readonly property real spring: 12.0
        readonly property real epsilon: 0.01
        readonly property int durationMs: root.reducedMotion ? root.reducedMotionFadeMs : 120
    }

    readonly property QtObject springDefaultEffects: QtObject {
        readonly property real damping: 1.0
        readonly property real spring: 6.0
        readonly property real epsilon: 0.01
        readonly property int durationMs: root.reducedMotion ? root.reducedMotionFadeMs : 220
    }

    // Hold-to-confirm for destructive actions (M3HoldToConfirm). The fill is information, not decoration,
    // so Reduced Motion never shortens the hold; only the release drain collapses to a crossfade.
    readonly property int holdToConfirmMs: 2000
    readonly property int holdDrainMs: reducedMotion ? reducedMotionFadeMs : 200
    readonly property real holdTapHintThreshold: 0.15 // released before 15% = a tap: play the visual nudge (fill peeks to this value, then drains)

    // Standard M3 Cubic-Bezier Curves (for NumberAnimation / ColorAnimation)
    readonly property var curveEmphasized: [0.2, 0.0, 0.0, 1.0, 1.0, 1.0]
    readonly property var curveEmphasizedDecelerate: [0.05, 0.7, 0.1, 1.0, 1.0, 1.0]
    readonly property var curveEmphasizedAccelerate: [0.3, 0.0, 0.8, 0.15, 1.0, 1.0]
    readonly property var curveStandard: [0.2, 0.0, 0.0, 1.0, 1.0, 1.0]

    // Duration Tokens (ms) — collapse to a short crossfade under Reduced Motion
    function capped(ms: int): int {
        return reducedMotion ? Math.min(ms, reducedMotionFadeMs) : ms
    }
    readonly property int durationShort1: capped(50)
    readonly property int durationShort2: capped(100)
    readonly property int durationShort3: capped(150)
    readonly property int durationShort4: capped(200)
    readonly property int durationMedium1: capped(250)
    readonly property int durationMedium2: capped(300)
    readonly property int durationMedium3: capped(350)
    readonly property int durationMedium4: capped(400)
    readonly property int durationLong1: capped(450)
    readonly property int durationLong2: capped(500)
}
