import QtQuick
import QtQuick.Shapes

// The HowlStore tote bag, drawn in a 160 × 160 box. It holds a bowl, a bone and a tennis ball in the accent color;
// `filled` says how many show (they drop in and pop out). The app's icon sits on the handle.
// showApp(): the app climbs out of the bag; hideApp(): it drops back in. `app` true/false sets it without moving.
Item {
    id: bag
    property string icon
    property int filled: 0
    property bool failed: false
    property bool app: false
    implicitWidth: 170
    implicitHeight: 170

    function showApp() { appIn.stop(); appOut.restart() }
    function hideApp() { appOut.stop(); appIn.restart() }
    onAppChanged: { appIn.stop(); appOut.stop(); appY = 0; appTurn = 0; appWide = 1; appTall = 1; appShown = app ? 1 : 0 }
    // Sets the items without animation
    function fill(count) { for (let i = 0; i < things.count; ++i) things.itemAt(i).set(i < count) }

    Draw { id: draw }
    readonly property string outline: "M3720.815,2006.166L4018.853,2006.166C4276.944,2006.166 4486.481,2215.704 4486.481,2473.795L4486.481,4018.853C4486.481,4276.944 4276.944,4486.481 4018.853,4486.481L941.777,4486.481C683.686,4486.481 474.149,4276.944 474.149,4018.853L474.149,2473.795C474.149,2215.704 683.686,2006.166 941.777,2006.166L1239.815,2006.166L1239.815,1668.477C1239.815,1431.892 1431.892,1239.815 1668.477,1239.815L3292.153,1239.815C3528.738,1239.815 3720.815,1431.892 3720.815,1668.477L3720.815,2006.166Z"
        + "M1554.586,2368.416C1554.586,2518.138 1676.141,2639.693 1825.862,2639.693L3134.768,2639.693C3284.489,2639.693 3406.044,2518.138 3406.044,2368.416L3406.044,1825.863C3406.044,1676.141 3284.489,1554.586 3134.768,1554.586L1825.862,1554.586C1676.141,1554.586 1554.586,1676.141 1554.586,1825.863L1554.586,2368.416Z"
    readonly property real bodyTop: 46 + (2006 - 1239) * 0.0329
    readonly property color thingColor: failed ? palette.mid : palette.active.highlight

    property real appY: 0
    property real appTurn: 0
    property real appWide: 1
    property real appTall: 1
    property real appShown: 0

    // Climbs out of the bag spinning, lands on the handle with a squash
    SequentialAnimation {
        id: appOut
        ScriptAction { script: { bag.appY = 80; bag.appTurn = 0; bag.appWide = 1; bag.appTall = 1; bag.appShown = 1 } }
        ParallelAnimation {
            NumberAnimation { target: bag; property: "appY"; to: -34; duration: 480; easing.type: Easing.InOutCubic }
            NumberAnimation { target: bag; property: "appTurn"; to: -180; duration: 480; easing.type: Easing.InOutCubic }
            NumberAnimation { target: bag; properties: "appWide,appTall"; to: 1.05; duration: 480 }
        }
        ParallelAnimation {
            NumberAnimation { target: bag; property: "appY"; to: -42; duration: 225; easing.type: Easing.InOutCubic }
            NumberAnimation { target: bag; property: "appTurn"; to: -360; duration: 225; easing.type: Easing.InOutCubic }
            NumberAnimation { target: bag; properties: "appWide,appTall"; to: 1.1; duration: 225 }
        }
        ParallelAnimation {
            NumberAnimation { target: bag; property: "appY"; to: 3; duration: 290; easing.type: Easing.InOutCubic }
            NumberAnimation { target: bag; property: "appWide"; to: 1.2; duration: 290 }
            NumberAnimation { target: bag; property: "appTall"; to: 0.8; duration: 290 }
        }
        ParallelAnimation {
            NumberAnimation { target: bag; property: "appY"; to: -10; duration: 225; easing.type: Easing.InOutCubic }
            NumberAnimation { target: bag; property: "appWide"; to: 0.94; duration: 225 }
            NumberAnimation { target: bag; property: "appTall"; to: 1.08; duration: 225 }
        }
        ParallelAnimation {
            NumberAnimation { target: bag; property: "appY"; to: 1; duration: 190; easing.type: Easing.InOutCubic }
            NumberAnimation { target: bag; property: "appWide"; to: 1.05; duration: 190 }
            NumberAnimation { target: bag; property: "appTall"; to: 0.95; duration: 190 }
        }
        ParallelAnimation {
            NumberAnimation { target: bag; property: "appY"; to: 0; duration: 190 }
            NumberAnimation { target: bag; properties: "appWide,appTall"; to: 1; duration: 190 }
        }
    }
    // Wobbles, hops, and drops back into the bag
    SequentialAnimation {
        id: appIn
        ScriptAction { script: { bag.appY = 0; bag.appTurn = 0; bag.appWide = 1; bag.appTall = 1; bag.appShown = 1 } }
        NumberAnimation { target: bag; property: "appTurn"; to: -14; duration: 140 }
        NumberAnimation { target: bag; property: "appTurn"; to: 12; duration: 140 }
        NumberAnimation { target: bag; property: "appTurn"; to: -6; duration: 120 }
        ParallelAnimation {
            NumberAnimation { target: bag; property: "appTurn"; to: 0; duration: 150 }
            NumberAnimation { target: bag; property: "appY"; to: -18; duration: 150; easing.type: Easing.OutCubic }
            NumberAnimation { target: bag; properties: "appWide,appTall"; to: 1.08; duration: 150 }
        }
        ParallelAnimation {
            NumberAnimation { target: bag; property: "appY"; to: 80; duration: 370; easing.type: Easing.InCubic }
            NumberAnimation { target: bag; properties: "appWide,appTall"; to: 1; duration: 370 }
        }
        NumberAnimation { target: bag; property: "appShown"; to: 0; duration: 80 }
    }

    Item {
        width: 160
        height: 160
        transformOrigin: Item.TopLeft
        scale: bag.width / 160

        // The bag behind, a little smaller, peeking over the top
        Item {
            x: 20.6; y: 37
            transformOrigin: Item.TopLeft
            scale: 0.0296
            Blob { x: -474; y: -1239; d: bag.outline; fill: draw.bagBack; fillRule: ShapePath.OddEvenFill }
        }
        // The app, behind the front of the bag: hidden while inside, seen through the handle as it climbs
        AppIcon {
            x: 55; y: -4
            width: 50; height: 50
            icon: bag.icon
            visible: bag.icon !== ""
            opacity: bag.appShown
            transform: [
                Scale { origin.x: 25; origin.y: 50; xScale: bag.appWide; yScale: bag.appTall },
                Rotation { origin.x: 25; origin.y: 50; angle: bag.appTurn },
                Translate { y: bag.appY }
            ]
        }
        Item {
            x: 14; y: 46
            transformOrigin: Item.TopLeft
            scale: 0.0329
            Blob { x: -474; y: -1239; d: bag.outline; fill: draw.bagFront; fillRule: ShapePath.OddEvenFill }
        }
        // The things inside, kept below the handle
        Item {
            y: bag.bodyTop
            width: 160
            height: 160 - bag.bodyTop
            clip: true
            opacity: bag.failed ? 0.55 : 1
            Item {
                y: -bag.bodyTop
                Repeater {
                    id: things
                    // Install order: bowl (right), bone (left), ball (middle)
                    model: [{ x: 123, y: 120, turn: -60 }, { x: 38, y: 111, turn: -14 }, { x: 75, y: 118, turn: 18 }]
                    Item {
                        id: thing
                        required property var modelData
                        required property int index
                        x: modelData.x
                        y: modelData.y
                        rotation: modelData.turn
                        readonly property bool wanted: index < bag.filled
                        property bool shown: false
                        property real dy: 0
                        property real spin: 0
                        property real size: 1
                        function set(on) { drop.stop(); poof.stop(); shown = on; dy = 0; spin = 0; size = 1; look.opacity = on ? 1 : 0 }
                        onWantedChanged: {
                            if (wanted === shown) return
                            shown = wanted
                            if (wanted) { poof.stop(); drop.restart() } else { drop.stop(); poof.restart() }
                        }
                        // Falls in from above with a little bounce
                        SequentialAnimation {
                            id: drop
                            ScriptAction { script: { thing.dy = -60; thing.spin = -30; thing.size = 0.6; look.opacity = 0 } }
                            ParallelAnimation {
                                NumberAnimation { target: thing; properties: "dy,spin"; to: 0; duration: 550; easing.type: Easing.OutBack }
                                NumberAnimation { target: thing; property: "size"; to: 1; duration: 550; easing.type: Easing.OutBack }
                                NumberAnimation { target: look; property: "opacity"; to: 1; duration: 220 }
                            }
                        }
                        // Pops up and vanishes
                        SequentialAnimation {
                            id: poof
                            ParallelAnimation {
                                NumberAnimation { target: thing; property: "dy"; to: -8; duration: 160; easing.type: Easing.InQuad }
                                NumberAnimation { target: thing; property: "size"; to: 1.2; duration: 160 }
                            }
                            ParallelAnimation {
                                NumberAnimation { target: thing; property: "dy"; to: -22; duration: 290; easing.type: Easing.InCubic }
                                NumberAnimation { target: thing; property: "size"; to: 0.1; duration: 290; easing.type: Easing.InCubic }
                                NumberAnimation { target: thing; property: "spin"; to: 160; duration: 290; easing.type: Easing.InCubic }
                                NumberAnimation { target: look; property: "opacity"; to: 0; duration: 290; easing.type: Easing.InCubic }
                            }
                        }
                        Item {
                            id: look
                            opacity: 0
                            transform: [
                                Scale { xScale: thing.size; yScale: thing.size },
                                Rotation { angle: thing.spin },
                                Translate { y: thing.dy }
                            ]
                            // Bowl, with a paw on its side
                            Item {
                                visible: thing.index === 0
                                scale: 1.07
                                transformOrigin: Item.TopLeft
                                Blob { d: "M-26 -12 H26 Q28 -12 27 -9 L20 9 Q19 12 15 12 H-15 Q-19 12 -20 9 L-27 -9 Q-28 -12 -26 -12 Z"; fill: bag.thingColor }
                                Blob { d: draw.rect(-30, -16, 60, 6, 3); fill: bag.thingColor }
                                Item {
                                    x: -8.4; y: -6.7
                                    scale: 0.7
                                    transformOrigin: Item.TopLeft
                                    Blob { d: draw.paw; fill: draw.bagFront }
                                }
                            }
                            // Bone: two round lobes at each end
                            Blob {
                                visible: thing.index === 1
                                d: draw.rect(-5.7, -24.3, 11.4, 48.6) + draw.circle(-6.9, -24.3, 6.7) + draw.circle(6.9, -24.3, 6.7)
                                   + draw.circle(-6.9, 24.3, 6.7) + draw.circle(6.9, 24.3, 6.7)
                                fill: bag.thingColor
                            }
                            // Tennis ball
                            Item {
                                visible: thing.index === 2
                                Blob { d: draw.circle(0, 0, 18.5); fill: bag.thingColor }
                                Blob { d: "M-13.1 -13.1 Q-3.2 0 -13.1 13.1 M13.1 -13.1 Q3.2 0 13.1 13.1"; stroke: draw.bagFront; strokeWidth: 3 }
                            }
                        }
                    }
                }
            }
        }
    }
}
