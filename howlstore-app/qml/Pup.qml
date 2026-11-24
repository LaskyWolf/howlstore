import QtQuick

// The standing pup, drawn in a 114 × 80 box with its feet on the bottom edge.
// `pose`: idle, walk, wag, bark, happy, crouch, slide, sad. wake() and hop() play once.
Item {
    id: pup
    property string pose: "idle"
    implicitWidth: 86
    implicitHeight: 60

    function wake() {
        wakeY = 16; wakeTurn = 0; wakeStretch = 0.85
        wakeAnimation.restart()
    }
    function hop() { hopAnimation.restart() }

    // Where each part rests in this pose; loops below add movement on top
    property real frontTurn: ({ happy: -18, crouch: -28, slide: -82 })[pose] ?? 0
    property real backTurn: ({ crouch: 32, slide: 82 })[pose] ?? 0
    property real tailTurn: ({ slide: -58, sad: -72 })[pose] ?? 0
    property real earFrontTurn: ({ crouch: -20, slide: -48, sad: -50 })[pose] ?? 0
    property real earBackTurn: ({ crouch: -20, slide: -48, sad: -40 })[pose] ?? 0
    property real headTurn: ({ crouch: -4, slide: -8, sad: 18 })[pose] ?? 0
    property real headDrop: ({ crouch: 3, sad: 2 })[pose] ?? 0
    property real bodyDrop: ({ crouch: 6, slide: 16 })[pose] ?? 0
    property real mouth: ["bark", "happy", "slide"].includes(pose) ? 1 : 0
    property real dust: pose === "slide" ? 1 : 0
    Behavior on frontTurn { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
    Behavior on backTurn { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
    Behavior on tailTurn { NumberAnimation { duration: 300 } }
    Behavior on earFrontTurn { NumberAnimation { duration: 300 } }
    Behavior on earBackTurn { NumberAnimation { duration: 300 } }
    Behavior on headTurn { NumberAnimation { duration: 300 } }
    Behavior on headDrop { NumberAnimation { duration: 300 } }
    Behavior on bodyDrop { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
    Behavior on mouth { NumberAnimation { duration: 150 } }
    Behavior on dust { NumberAnimation { duration: 200 } }

    // Loops. A change of pose first eases every loop back to rest, then starts the loops of the new pose.
    property real legSwing: 0
    property real bob: 0
    property real wagging: 0
    property real tilt: 0
    property real bark: 0
    property real bounce: 0
    property real wiggle: 0
    property real spray: 0
    readonly property bool looping: !settle.running
    onPoseChanged: settle.restart()
    ParallelAnimation {
        id: settle
        NumberAnimation { target: pup; properties: "legSwing,bob,wagging,tilt,bark,bounce,wiggle"; to: 0; duration: 250; easing.type: Easing.OutCubic }
    }
    SequentialAnimation on legSwing {
        running: pup.looping && pup.pose === "walk"
        loops: Animation.Infinite
        NumberAnimation { from: 22; to: -22; duration: 500; easing.type: Easing.InOutSine }
        NumberAnimation { from: -22; to: 22; duration: 500; easing.type: Easing.InOutSine }
    }
    SequentialAnimation on bob {
        running: pup.looping && pup.pose === "walk"
        loops: Animation.Infinite
        NumberAnimation { from: 0; to: -1.5; duration: 250; easing.type: Easing.InOutSine }
        NumberAnimation { from: -1.5; to: 0; duration: 250; easing.type: Easing.InOutSine }
    }
    SequentialAnimation on wagging {
        id: wag
        readonly property int half: ["walk", "idle"].includes(pup.pose) ? 600 : 150
        running: pup.looping && ["walk", "idle", "wag", "crouch", "bark", "happy"].includes(pup.pose)
        loops: Animation.Infinite
        NumberAnimation { from: -16; to: 14; duration: wag.half; easing.type: Easing.InOutSine }
        NumberAnimation { from: 14; to: -16; duration: wag.half; easing.type: Easing.InOutSine }
    }
    SequentialAnimation on tilt {
        running: pup.looping && pup.pose === "wag"
        loops: Animation.Infinite
        PauseAnimation { duration: 1080 }
        NumberAnimation { from: 0; to: -10; duration: 270; easing.type: Easing.InOutSine }
        NumberAnimation { from: -10; to: 0; duration: 450; easing.type: Easing.InOutSine }
    }
    SequentialAnimation on bark {
        running: pup.looping && pup.pose === "bark"
        loops: Animation.Infinite
        NumberAnimation { from: 0; to: 1; duration: 300; easing.type: Easing.InOutSine }
        NumberAnimation { from: 1; to: 0; duration: 300; easing.type: Easing.InOutSine }
    }
    SequentialAnimation on bounce {
        running: pup.looping && pup.pose === "happy"
        loops: Animation.Infinite
        NumberAnimation { from: 0; to: -9; duration: 170; easing.type: Easing.OutCubic }
        NumberAnimation { from: -9; to: 0; duration: 250; easing.type: Easing.InCubic }
    }
    SequentialAnimation on wiggle {
        running: pup.looping && pup.pose === "crouch"
        loops: Animation.Infinite
        NumberAnimation { from: -1.5; to: 1.5; duration: 280; easing.type: Easing.InOutSine }
        NumberAnimation { from: 1.5; to: -1.5; duration: 280; easing.type: Easing.InOutSine }
    }
    NumberAnimation on spray { running: pup.pose === "slide"; loops: Animation.Infinite; from: 0; to: 1; duration: 420 }

    // Played once: getting up out of bed, and a little hop
    property real wakeY: 0
    property real wakeTurn: 0
    property real wakeStretch: 1
    property real hopY: 0
    SequentialAnimation {
        id: wakeAnimation
        ParallelAnimation {
            NumberAnimation { target: pup; property: "wakeY"; to: 8; duration: 490; easing.type: Easing.InOutCubic }
            NumberAnimation { target: pup; property: "wakeTurn"; to: 9; duration: 490; easing.type: Easing.InOutCubic }
            NumberAnimation { target: pup; property: "wakeStretch"; to: 1; duration: 490; easing.type: Easing.InOutCubic }
        }
        ParallelAnimation {
            NumberAnimation { target: pup; property: "wakeY"; to: -5; duration: 490; easing.type: Easing.InOutCubic }
            NumberAnimation { target: pup; property: "wakeTurn"; to: -1; duration: 490; easing.type: Easing.InOutCubic }
        }
        ParallelAnimation {
            NumberAnimation { target: pup; property: "wakeY"; to: 0; duration: 420; easing.type: Easing.InOutCubic }
            NumberAnimation { target: pup; property: "wakeTurn"; to: 0; duration: 420; easing.type: Easing.InOutCubic }
        }
    }
    SequentialAnimation {
        id: hopAnimation
        NumberAnimation { target: pup; property: "hopY"; to: -12; duration: 180; easing.type: Easing.OutCubic }
        NumberAnimation { target: pup; property: "hopY"; to: 0; duration: 270; easing.type: Easing.InCubic }
    }

    component Leg: Item {
        // A straight front leg: a rounded bar and a foot
        property real at
        property bool far
        property real turn
        Draw { id: legDraw }
        transform: Rotation { origin.x: at + 6.5; origin.y: 49.4; angle: turn }
        Blob { d: legDraw.rect(at, 47, 8.5, 20, 4.25); fill: far ? legDraw.dark : legDraw.body }
        Blob { d: legDraw.ellipse(at + 6.5, 67.5, 6.5, 3.6); fill: far ? legDraw.dark : legDraw.cream }
    }
    component BentLeg: Item {
        // A back leg with a bent knee
        property real at
        property bool far
        property real turn
        Draw { id: bentDraw }
        transform: Rotation { origin.x: at + 5.25; origin.y: 48.5; angle: turn }
        Blob { d: `M${at + 4} 46 L${at - 2} 57 L${at + 2} 66`; stroke: far ? bentDraw.dark : bentDraw.body; strokeWidth: 8.5 }
        Blob { d: bentDraw.ellipse(at + 6, 67.5, 6.5, 3.6); fill: far ? bentDraw.dark : bentDraw.cream }
    }
    Draw { id: draw }

    Item {
        id: art
        width: 114
        height: 80
        transformOrigin: Item.TopLeft
        scale: pup.width / 114
        transform: Translate { y: pup.hopY }

        Item {  // Drawing units: the box starts at y = -6
            y: 6
            Repeater {  // Dust behind a belly slide
                model: [[98, 68, 3], [102, 70, 2.4], [95, 70, 2]]
                Blob {
                    required property var modelData
                    required property int index
                    readonly property real t: (pup.spray + index / 3) % 1
                    d: draw.circle(modelData[0], modelData[1], modelData[2])
                    fill: draw.cream
                    opacity: pup.dust * 0.95 * (1 - t)
                    transform: [
                        Scale { origin.x: modelData[0]; origin.y: modelData[1]; xScale: 0.4 + 0.85 * t; yScale: xScale },
                        Translate { x: 12 * t; y: -10 * t }
                    ]
                }
            }
            Item {
                id: all
                transform: [
                    Scale { origin.x: 61; origin.y: 71; yScale: pup.wakeStretch },
                    Rotation { origin.x: 61; origin.y: 71; angle: pup.wiggle + pup.wakeTurn },
                    Translate { y: pup.bodyDrop + pup.bob - 2 * pup.bark + pup.bounce + pup.wakeY }
                ]
                BentLeg { at: 37; far: true; turn: pup.backTurn - pup.legSwing }
                Leg { at: 77; far: true; turn: pup.frontTurn + pup.legSwing }
                Item {
                    transform: Rotation { origin.x: 24; origin.y: 38; angle: pup.tailTurn + pup.wagging }
                    Blob { d: "M24 38 C14 36 9 26 11 15"; stroke: draw.body; strokeWidth: 6.5 }
                }
                Blob { d: "M20 42 C20 31 30 28 44 29 L70 29 C82 29 90 35 90 44 C90 53 83 57 72 57 L34 57 C25 57 20 51 20 42 Z"; fill: draw.body }
                Blob { d: draw.ellipse(83, 47, 6.5, 8); fill: draw.cream }
                Item {
                    x: 84
                    y: 33
                    transform: [
                        Rotation { origin.x: 0; origin.y: 2.6; angle: pup.headTurn + pup.tilt - 16 * pup.bark },
                        Translate { y: pup.headDrop - 2 * pup.bark }
                    ]
                    PupHead { mouth: pup.mouth; earFront: pup.earFrontTurn; earBack: pup.earBackTurn }
                }
                BentLeg { at: 30; turn: pup.backTurn + pup.legSwing }
                Leg { at: 70; turn: pup.frontTurn - pup.legSwing }
            }
        }
    }
}
