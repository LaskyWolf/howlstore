import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes

// The top of the System Update window: the pup sleeps while the sky turns from night to dawn with the progress.
// Six strips at the top of the sky and six paws below it mark the steps. When the update is done, a bone flies in
// and lands at the pup's paws, and the pup wakes up. When it fails, the pup jumps up sad.
ColumnLayout {
    id: scene
    property var steps: []
    property int step: 0
    property real fraction: 0       // The active step's own progress
    property real progress: 0
    property bool ok: false
    property bool failed: false
    property string line: ""
    spacing: 12

    readonly property color negative: "#da4453"
    readonly property real f: ok ? 1 : progress
    property real shown: f
    Behavior on shown { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
    readonly property bool ended: ok || failed
    property bool awake: false

    onOkChanged: if (ok) { awake = false; bone.fling(); sparks.play(500); wakeTimer.restart() }
    onFailedChanged: if (failed) { awake = true; awakePup.hop(); bang.pop() }
    Timer { id: wakeTimer; interval: 850; onTriggered: { scene.awake = true; awakePup.wake() } }
    // A "z" floats up each time a new line of output arrives, three at most
    onLineChanged: if (!ended && zs.count < 3) zs.model = zs.count + 1

    function skyColor(t) {
        const stops = [[0, [29, 45, 99]], [0.45, [74, 58, 120]], [0.8, [232, 138, 74]], [1, [246, 196, 106]]]
        for (let i = 1; i < stops.length; ++i) {
            if (t > stops[i][0]) continue
            const [a, ca] = stops[i - 1], [b, cb] = stops[i], u = (t - a) / (b - a)
            const c = ca.map((v, j) => (v + (cb[j] - v) * u) / 255)
            return Qt.rgba(c[0], c[1], c[2], 1)
        }
        return Qt.rgba(246 / 255, 196 / 255, 106 / 255, 1)
    }
    function mix(a, b, amount) { return Qt.rgba(a.r + (b.r - a.r) * amount, a.g + (b.g - a.g) * amount, a.b + (b.b - a.b) * amount, 1) }

    // ── Percent, step and the current line ──
    RowLayout {
        spacing: 14
        Layout.fillWidth: true
        Label {
            text: scene.failed ? "Stopped" : Math.round(scene.shown * 100) + "<small>%</small>"
            textFormat: Text.StyledText
            color: scene.failed ? scene.negative : palette.windowText
            font.pointSize: Application.font.pointSize * 2.6
            font.bold: true
        }
        ColumnLayout {
            spacing: 2
            Layout.fillWidth: true
            Label {
                text: scene.ok ? "Good morning! Everything is up to date"
                    : scene.failed ? (scene.steps[scene.step] ?? "") + " did not finish"
                    : (scene.steps[scene.step] ?? "") + " · step " + (scene.step + 1) + " of " + scene.steps.length
                font.bold: true
                font.pointSize: Application.font.pointSize + 2
                elide: Text.ElideRight
                textFormat: Text.PlainText
                Layout.fillWidth: true
            }
            Label {
                text: scene.ok ? "All steps done" : scene.line
                color: palette.placeholderText
                font.family: "monospace"
                font.pointSize: Application.font.pointSize - 1
                elide: Text.ElideRight
                textFormat: Text.PlainText
                Layout.fillWidth: true
            }
        }
    }

    // ── The sky ──
    Rectangle {
        id: sky
        Layout.fillWidth: true
        Layout.preferredHeight: 190
        radius: 10
        clip: true
        color: scene.mix(palette.window, scene.skyColor(scene.shown), 0.28)
        readonly property real bx: width / 2
        Draw { id: draw }

        Item {  // Stars, fading as the sun comes up
            anchors.fill: parent
            opacity: Math.max(0, 1 - scene.shown * 1.4)
            Repeater {
                model: 22
                Rectangle {
                    id: star
                    required property int index
                    x: sky.width * ((index * 37) % 96 + 2) / 100
                    y: sky.height * ((index * 53) % 62 + 4) / 100
                    width: 3; height: 3; radius: 1.5
                    color: palette.windowText
                    opacity: 0.5
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        PauseAnimation { duration: (star.index * 370) % 2400 }
                        NumberAnimation { to: 0.1; duration: 1200; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 0.5; duration: 1200; easing.type: Easing.InOutSine }
                    }
                }
            }
        }
        Item {  // The sun climbs over the hills
            x: sky.width * 0.78 - 28
            y: sky.height - (-56 + scene.shown * 150) - 56
            width: 56; height: 56
            readonly property color tone: scene.failed ? scene.negative : "#f8c25a"
            Shape {  // A soft glow
                id: glow
                anchors.centerIn: parent
                width: 160; height: 160
                preferredRendererType: Shape.CurveRenderer
                ShapePath {
                    strokeColor: "transparent"
                    fillGradient: RadialGradient {
                        centerX: 80; centerY: 80; centerRadius: 80; focalX: 80; focalY: 80
                        GradientStop { position: 0.3; color: Qt.alpha(glow.parent.tone, 0.45) }
                        GradientStop { position: 1; color: Qt.alpha(glow.parent.tone, 0) }
                    }
                    PathSvg { path: "M0 80 A80 80 0 1 0 160 80 A80 80 0 1 0 0 80 Z" }
                }
            }
            Rectangle { anchors.fill: parent; radius: 28; color: parent.tone }
        }
        Item {  // Two hills, stretched across the sky
            anchors.bottom: parent.bottom
            width: 528; height: 60
            transform: Scale { xScale: sky.width / 528 }
            Blob { d: "M0 34 Q90 6 190 28 T380 22 T528 30 V60 H0Z"; fill: scene.mix(palette.window, Qt.rgba(0, 0, 0, 1), 0.15) }
            Blob { d: "M0 46 Q120 26 260 42 T528 40 V60 H0Z"; fill: scene.mix(palette.window, Qt.rgba(0, 0, 0, 1), 0.3) }
        }
        RowLayout {  // One strip per step
            x: 14; y: 12
            width: sky.width - 28
            spacing: 4
            Repeater {
                model: scene.steps.length
                Rectangle {
                    required property int index
                    readonly property bool bad: scene.failed && index === scene.step
                    Layout.fillWidth: true
                    height: 4; radius: 2
                    color: Qt.alpha(palette.windowText, 0.2)
                    clip: true
                    Rectangle {
                        height: parent.height; radius: 2
                        color: parent.bad ? scene.negative : "#f5c542"
                        width: parent.width * (scene.ok || parent.index < scene.step || parent.bad ? 1 : parent.index === scene.step ? scene.fraction : 0)
                        Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                    }
                }
            }
        }
        Rectangle {  // The bed
            x: sky.bx - 75; y: sky.height - 8 - 22
            width: 150; height: 22
            topLeftRadius: 40; topRightRadius: 40; bottomLeftRadius: 12; bottomRightRadius: 12
            color: scene.mix(palette.window, palette.windowText, 0.16)
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 5; bottomLeftRadius: 12; bottomRightRadius: 12; color: Qt.rgba(0, 0, 0, 0.15) }
        }
        SleepyPup {
            x: sky.bx - 62; y: sky.height - 12 - 76
            width: 130; height: 76
            opacity: scene.awake ? 0 : 1
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 250 } }
        }
        Pup {
            id: awakePup
            x: sky.bx - 57; y: sky.height - 14 - 80
            width: 114; height: 80
            pose: scene.failed ? "sad" : scene.ok ? "wag" : "idle"
            opacity: scene.awake ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }
        Label {
            id: bang
            x: sky.bx + 52; y: sky.height - 84 - height
            text: "!"
            color: scene.negative
            font.pixelSize: 22
            font.weight: Font.ExtraBold
            opacity: 0
            function pop() { popIn.restart() }
            ParallelAnimation {
                id: popIn
                NumberAnimation { target: bang; property: "opacity"; from: 0; to: 1; duration: 240 }
                NumberAnimation { target: bang; property: "scale"; from: 0.2; to: 1; duration: 400; easing.type: Easing.OutBack }
            }
        }
        Repeater {  // Zzz while asleep
            id: zs
            model: 0
            Label {
                id: zed
                required property int index
                text: "z"
                font.bold: true
                font.pixelSize: 12 + index * 3
                property real t: 0
                x: sky.bx + 40 + 30 * t
                y: sky.height - 70 - height - 50 * t
                opacity: t < 0.2 ? 0.9 * t / 0.2 : 0.9 * (1 - (t - 0.2) / 0.8)
                scale: 0.6 + 0.6 * t
                visible: !scene.ended
                NumberAnimation on t { from: 0; to: 1; duration: 2600; easing.type: Easing.OutQuad; onFinished: if (zed.index === zs.count - 1) zs.model = 0 }
            }
        }
        Sparks { id: sparks; x: sky.bx; y: sky.height * 0.62 }
        Item {  // The bone flung in from the right; it lands at the pup's front paws
            id: bone
            property real t: 0
            property real lift: 0
            property real spin: 0
            function fling() { flight.restart() }
            readonly property real from: sky.width + 10
            readonly property real to: sky.bx + 46
            x: from + (to - from) * t
            y: sky.height - 10 - 16 + lift
            width: 40; height: 16
            rotation: spin
            visible: t > 0
            Item {
                scale: 40 / 46
                transformOrigin: Item.TopLeft
                Blob { d: draw.bone; fill: draw.cream }
            }
            ParallelAnimation {
                id: flight
                NumberAnimation { target: bone; property: "t"; from: 0.001; to: 1; duration: 900; easing.type: Easing.OutCubic }
                SequentialAnimation {
                    ParallelAnimation {
                        NumberAnimation { target: bone; property: "lift"; from: -60; to: -120; duration: 360; easing.type: Easing.OutQuad }
                        NumberAnimation { target: bone; property: "spin"; from: 0; to: -260; duration: 360 }
                    }
                    ParallelAnimation {
                        NumberAnimation { target: bone; property: "lift"; to: 0; duration: 360; easing.type: Easing.InQuad }
                        NumberAnimation { target: bone; property: "spin"; to: -540; duration: 360 }
                    }
                    NumberAnimation { target: bone; property: "lift"; to: -8; duration: 70 }
                    NumberAnimation { target: bone; property: "lift"; to: 0; duration: 110; easing.type: Easing.InQuad }
                }
            }
        }
    }

    // ── One paw per step ──
    RowLayout {
        Layout.fillWidth: true
        spacing: 6
        Repeater {
            model: scene.steps
            ColumnLayout {
                id: paw
                required property string modelData
                required property int index
                readonly property bool done: scene.ok || index < scene.step
                readonly property bool bad: scene.failed && index === scene.step
                readonly property bool active: !scene.ended && index === scene.step
                spacing: 2
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                Item {
                    id: pawIcon
                    Layout.alignment: Qt.AlignHCenter
                    width: 16; height: 16
                    Draw { id: pawDraw }
                    Item {
                        scale: 16 / 24
                        transformOrigin: Item.TopLeft
                        Blob { d: pawDraw.paw; fill: paw.bad ? scene.negative : paw.done ? "#f5c542" : paw.active ? palette.windowText : palette.mid }
                    }
                    SequentialAnimation on opacity {
                        running: paw.active
                        loops: Animation.Infinite
                        onRunningChanged: if (!running) pawIcon.opacity = 1
                        NumberAnimation { to: 0.35; duration: 500 }
                        NumberAnimation { to: 1; duration: 500 }
                    }
                }
                Label {
                    text: paw.modelData
                    color: paw.bad ? scene.negative : paw.active ? palette.windowText : palette.placeholderText
                    font.bold: paw.active
                    font.pointSize: Application.font.pointSize - 1.5
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    textFormat: Text.PlainText
                    Layout.fillWidth: true
                }
            }
        }
    }
}
