import QtQuick

// SVG path text for the pup drawings, and their colors. Every shape winds the same way, so shapes of one
// color can share a path and still fill where they overlap.
QtObject {
    readonly property color body: "#62d946"
    readonly property color dark: "#3a9c2d"
    readonly property color cream: "#f4f1e4"
    readonly property color nose: "#1e2619"
    readonly property color collar: "#e0453a"
    readonly property color tag: "#f5c542"
    readonly property color innerEar: "#f2a99f"
    readonly property color bagFront: "#e1e5e8"
    readonly property color bagBack: "#a9b6c6"

    // An ellipse, turned by `angle` degrees around its centre
    function ellipse(cx, cy, rx, ry, angle) {
        const a = (angle ?? 0) * Math.PI / 180, dx = rx * Math.cos(a), dy = rx * Math.sin(a)
        return `M${cx - dx} ${cy - dy} A${rx} ${ry} ${angle ?? 0} 1 0 ${cx + dx} ${cy + dy} A${rx} ${ry} ${angle ?? 0} 1 0 ${cx - dx} ${cy - dy} Z`
    }
    function circle(cx, cy, r) { return ellipse(cx, cy, r, r, 0) }
    function rect(x, y, w, h, r) {
        if (!r) return `M${x} ${y} L${x} ${y + h} L${x + w} ${y + h} L${x + w} ${y} Z`
        return `M${x} ${y + r} L${x} ${y + h - r} A${r} ${r} 0 0 0 ${x + r} ${y + h} L${x + w - r} ${y + h} A${r} ${r} 0 0 0 ${x + w} ${y + h - r}`
             + ` L${x + w} ${y + r} A${r} ${r} 0 0 0 ${x + w - r} ${y} L${x + r} ${y} A${r} ${r} 0 0 0 ${x} ${y + r} Z`
    }
    // A paw print in a 24 × 24 box
    readonly property string paw: ellipse(12, 16.2, 5.6, 4.6) + ellipse(4.6, 10, 2.2, 2.9, -20) + ellipse(9.2, 5.6, 2.3, 3)
        + ellipse(14.8, 5.6, 2.3, 3) + ellipse(19.4, 10, 2.2, 2.9, 20)
    // A small bone in a 46 × 18 box
    readonly property string bone: rect(6, 5, 34, 8, 4) + circle(6, 5, 5) + circle(6, 13, 5) + circle(40, 5, 5) + circle(40, 13, 5)
}
