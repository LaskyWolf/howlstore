import QtQuick
import QtQuick.Shapes

// One SVG path, filled or stroked, in its parent's units.
Shape {
    id: blob
    property string d
    property color fill: "transparent"
    property color stroke: "transparent"
    property real strokeWidth: 0
    property int fillRule: ShapePath.WindingFill
    preferredRendererType: Shape.CurveRenderer
    ShapePath {
        fillColor: blob.fill
        fillRule: blob.fillRule
        strokeColor: blob.stroke
        strokeWidth: blob.strokeWidth > 0 ? blob.strokeWidth : -1
        capStyle: ShapePath.RoundCap
        joinStyle: ShapePath.RoundJoin
        PathSvg { path: blob.d }
    }
}
