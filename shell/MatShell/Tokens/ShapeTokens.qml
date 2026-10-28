pragma Singleton
import QtQuick
import Quickshell

/**
 * ShapeTokens.qml — Material 3 Corner Radii, Interactive Morph Helpers & Expressive Polygon Catalog
 */
Singleton {
    id: root

    // Standard Rectangular Corner Radii (px)
    readonly property int none: 0
    readonly property int xxs: 2
    readonly property int xs: 4
    readonly property int sm: 8
    readonly property int md: 12
    readonly property int lg: 16
    readonly property int xl: 24
    readonly property int xxl: 28
    readonly property int full: 9999

    // M3 Expressive Non-Rectangular Polygon Identifiers
    readonly property string polygonScallop12: "scallop_12"          // 12-bump "cookie" badge
    readonly property string polygonClover4: "clover_4"              // 4-leaf clover frame
    readonly property string polygonFlower8: "flower_8"              // 8-petal flower badge
    readonly property string polygonHexagon: "hexagon"               // Rounded flat-top hexagon tile
    readonly property string polygonDiamond: "diamond"               // Rounded rhombus (vertex at top)
    readonly property string polygonTriangle: "rounded_triangle"     // Rounded triangle — icon-only content
    readonly property string polygonSlantedPill: "slanted_pill"      // -10deg skewed capsule (M3Surface + skew transform, not sampled)

    /**
     * Polar geometry for every sampled polygon.
     * - "lobed": r = 1 - depth + depth * u^sharpness, u = (1 + cos(lobes * theta')) / 2. sharpness < 1 gives round petals with tight notches.
     * - "polygon": rounded regular polygon from a smooth-max of edge half-planes; higher sharpness = crisper corners.
     * safeContentRatio is the inscribed-circle radius (relative to the outer radius): content must stay inside it.
     */
    readonly property var polygonGeometry: ({
        "scallop_12":       { type: "lobed",   lobes: 12, depth: 0.10, sharpness: 0.5,  safeContentRatio: 0.88 },
        "flower_8":         { type: "lobed",   lobes: 8,  depth: 0.20, sharpness: 0.5,  safeContentRatio: 0.78 },
        "clover_4":         { type: "lobed",   lobes: 4,  depth: 0.30, sharpness: 0.45, safeContentRatio: 0.68 },
        "hexagon":          { type: "polygon", sides: 6,  rotation: 0.0,          sharpness: 18, safeContentRatio: 0.88 },
        "diamond":          { type: "polygon", sides: 4,  rotation: -Math.PI / 2, sharpness: 9,  safeContentRatio: 0.74 },
        "rounded_triangle": { type: "polygon", sides: 3,  rotation: -Math.PI / 2, sharpness: 6,  safeContentRatio: 0.54 }
    })

    /**
     * Computes the M3 Expressive interactive corner radius for a pill or button
     * that morphs from a resting capsule into a squircle when pressed or expanded.
     */
    function morphPillRadius(height: real, hovered: bool, pressed: bool, expanded: bool): real {
        if (pressed) return md       // 12px squircle on press squish
        if (expanded) return lg      // 16px rounded container when popover open
        if (hovered) return Math.min(height / 2, xl)
        return height / 2            // Full capsule at rest
    }

    /**
     * Computes the corner radius for a Quick Settings Tile that morphs from
     * a 16px rounded rectangle (inactive) into a full capsule (active) and 12px squircle (pressed).
     */
    function morphTileRadius(height: real, active: bool, pressed: bool): real {
        if (pressed) return md       // 12px on press
        if (active) return height / 2 // Full pill when active
        return lg                    // 16px rounded card when inactive
    }

    /**
     * Returns the normalized outer radius (0..1, 1 = widest point) of a polygon in direction `theta`
     * (radians, 0 = right, -PI/2 = top). Unknown kinds return a circle.
     */
    function polygonRadius(polygonKind: string, theta: real): real {
        const g = polygonGeometry[polygonKind]
        if (!g) return 1.0
        if (g.type === "lobed") {
            const u = (1.0 + Math.cos(g.lobes * (theta + Math.PI / 2.0))) / 2.0
            return 1.0 - g.depth + g.depth * Math.pow(u, g.sharpness)
        }
        const apothem = Math.cos(Math.PI / g.sides)
        let sum = 0.0
        for (let i = 0; i < g.sides; i++) {
            const normal = g.rotation + Math.PI / g.sides + i * 2.0 * Math.PI / g.sides
            const c = Math.cos(theta - normal)
            if (c > 0) sum += Math.pow(c, g.sharpness)
        }
        return (apothem / Math.pow(sum, 1.0 / g.sharpness)) * Math.pow(2.0, 1.0 / g.sharpness)
    }

    /**
     * Generates normalized (0..100 viewBox, outer radius 46) outline points so QtQuick Canvas / ShapePath
     * can render any M3 Expressive polygon. morphToCircleProgress (0..1) blends the outline into a circle
     * (0.35 on hover, 1.0 while pressed).
     */
    function samplePolygonPoints(polygonKind: string, sampleCount: int, morphToCircleProgress: real): var {
        const pts = []
        const m = Math.max(0.0, Math.min(1.0, morphToCircleProgress))
        for (let i = 0; i < sampleCount; i++) {
            const theta = (i / sampleCount) * Math.PI * 2.0 - Math.PI / 2.0
            const r = 46.0 * (polygonRadius(polygonKind, theta) * (1.0 - m) + m)
            pts.push(Qt.point(50.0 + r * Math.cos(theta), 50.0 + r * Math.sin(theta)))
        }
        return pts
    }

    /**
     * Inscribed-circle ratio for laying out content inside a polygon of the given kind.
     * Content diameter = itemWidth * 0.92 * polygonSafeContentRatio(kind).
     */
    function polygonSafeContentRatio(polygonKind: string): real {
        const g = polygonGeometry[polygonKind]
        return g ? g.safeContentRatio : 1.0
    }
}
