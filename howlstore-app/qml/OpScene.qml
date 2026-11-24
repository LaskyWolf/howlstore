import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// The top of the Install and Remove windows: the tote bag, a heading, and the pup walking along the progress rail.
// Install: the pup walks and leaves paw prints, things drop into the bag, the app climbs out when it is done and the pup barks.
// Remove: before it starts the person holds the box until it fills (or presses Enter); then the pup slides on its belly,
// things pop out of the bag, the app drops back in, and the pup bounces with hearts when it is done.
ColumnLayout {
    id: scene
    property bool removing: false
    property string icon
    property bool confirming: false   // Remove only: waiting for the hold
    property string holdNote: ""      // Under "Hold to remove"
    property real progress: 0
    property bool ok: false
    property bool failed: false
    property string heading
    property string subheading
    property string hint
    signal confirmed()

    spacing: 12
    readonly property color negative: "#da4453"
    readonly property real k: ok ? 1 : failed && removing ? 0 : progress
    property real shown: k
    Behavior on shown { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }
    readonly property real pupX: (track.width - pup.width) * shown

    // The things in the bag follow the progress
    readonly property int filled: removing ? (confirming || failed ? 3 : Math.ceil(3 * (1 - k)))
                                           : (ok ? 3 : Math.min(3, Math.floor(3 * k + 0.6)))
    property bool appGone: false
    onKChanged: if (removing && !confirming && !failed && k >= 0.7 && !appGone) { appGone = true; bag.hideApp() }
    onOkChanged: if (ok && !removing) { bag.showApp(); woofs.play(); sparks.play(900); barkTimer.restart() }
    onFailedChanged: if (failed) { shake.restart(); if (appGone) { appGone = false; bag.showApp() } }
    Component.onCompleted: { bag.fill(filled); bag.app = removing }

    property bool holding: false
    readonly property string pose: ok ? (removing ? "happy" : barkTimer.running ? "bark" : "wag")
        : failed ? "sad" : removing ? (confirming ? (holding ? "crouch" : "idle") : "slide") : "walk"
    Timer { id: barkTimer; interval: 1700 }

    // ── The bag ──
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 196  // Room above the bag for the app's jump
        transform: Translate { id: shakeX }
        SequentialAnimation {
            id: shake
            NumberAnimation { target: shakeX; property: "x"; to: -4; duration: 90 }
            NumberAnimation { target: shakeX; property: "x"; to: 4; duration: 90 }
            NumberAnimation { target: shakeX; property: "x"; to: -2; duration: 90 }
            NumberAnimation { target: shakeX; property: "x"; to: 2; duration: 90 }
            NumberAnimation { target: shakeX; property: "x"; to: 0; duration: 90 }
        }
        ToteBag {
            id: bag
            width: 170
            height: 170
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            icon: scene.icon
            filled: scene.filled
            failed: scene.failed && !scene.removing
        }
        Sparks { id: sparks; x: parent.width / 2; y: 20 }
    }

    // ── Heading ──
    ColumnLayout {
        spacing: 2
        Layout.fillWidth: true
        Label {
            text: scene.heading
            font.pointSize: Application.font.pointSize + 4
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            textFormat: Text.PlainText
            Layout.fillWidth: true
        }
        Label {
            text: scene.subheading
            visible: text !== ""
            color: palette.placeholderText
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            textFormat: Text.PlainText
            Layout.fillWidth: true
        }
    }

    // ── The rail with the pup ──
    Item {
        id: track
        Layout.fillWidth: true
        Layout.leftMargin: 6
        Layout.rightMargin: 6
        Layout.topMargin: 2
        Layout.preferredHeight: 66
        activeFocusOnTab: scene.confirming
        Accessible.role: scene.confirming ? Accessible.Button : Accessible.ProgressBar
        Accessible.name: scene.confirming ? "Hold to remove" : scene.heading
        Keys.onReturnPressed: if (scene.confirming) scene.confirmed()
        Keys.onEnterPressed: if (scene.confirming) scene.confirmed()
        Keys.onSpacePressed: if (scene.confirming) scene.confirmed()

        // Remove: the box to hold. It fills while held; letting go empties it.
        Rectangle {
            id: arm
            anchors.fill: parent
            anchors.margins: -6
            anchors.leftMargin: -8
            anchors.rightMargin: -8
            radius: 14
            color: "transparent"
            border.width: track.activeFocus ? 2 : 1.5
            border.color: track.activeFocus ? palette.highlight : scene.negative
            clip: true
            opacity: scene.confirming ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 300 } }
            Rectangle {
                id: charge
                property real amount: 0
                width: parent.width * amount
                height: parent.height
                radius: arm.radius
                color: Qt.alpha(scene.negative, 0.22)
                NumberAnimation { id: fillUp; target: charge; property: "amount"; to: 1; duration: 900 * (1 - charge.amount); onFinished: scene.confirmed() }
                NumberAnimation { id: drain; target: charge; property: "amount"; to: 0; duration: 250; easing.type: Easing.OutCubic }
            }
            MouseArea {
                anchors.fill: parent
                enabled: scene.confirming
                cursorShape: Qt.PointingHandCursor
                onPressed: { drain.stop(); fillUp.restart(); scene.holding = true }
                onReleased: letGo()
                onCanceled: letGo()
                function letGo() { if (!scene.confirming) return; fillUp.stop(); drain.restart(); scene.holding = false }
            }
            Column {
                x: 96
                y: 12
                width: parent.width - 96 - 8
                Label { text: "Hold to remove"; font.bold: true; width: parent.width; horizontalAlignment: Text.AlignHCenter }
                Label {
                    text: scene.holdNote
                    visible: text !== ""
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    color: palette.placeholderText
                    font.pointSize: Application.font.pointSize - 1
                }
            }
        }

        Rectangle {
            id: rail
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8
            height: 14
            radius: 7
            color: palette.alternateBase
            border.width: 1
            border.color: palette.mid
            clip: true
            Rectangle {
                id: bar
                height: parent.height
                radius: 7
                width: scene.removing && scene.failed ? 0
                    : scene.pupX + (scene.removing ? 52 + 34 * scene.shown : 16 + 70 * scene.shown)
                readonly property color main: scene.failed ? scene.negative : scene.removing && !scene.ok ? scene.negative : palette.active.highlight
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0; color: Qt.tint(palette.alternateBase, Qt.alpha(bar.main, scene.removing ? 0.25 : 0.45)) }
                    GradientStop { position: 1; color: bar.main }
                }
            }
            // Install: paw prints behind the walking pup
            Repeater {
                model: scene.removing ? 0 : Math.max(0, Math.floor((scene.pupX + 4) / 13))
                Item {
                    id: pawPrint
                    required property int index
                    x: 4 + index * 13
                    y: index % 2 ? 0.5 : 4.5
                    width: 9
                    height: 9
                    rotation: 90
                    opacity: 0.55
                    Draw { id: printDraw }
                    Item {
                        scale: 9 / 24
                        transformOrigin: Item.TopLeft
                        Blob { d: printDraw.paw; fill: Qt.darker(palette.active.highlight, 2.6) }
                    }
                    NumberAnimation on scale { from: 1.8; to: 1; duration: 350; easing.type: Easing.OutBack }
                }
            }
        }

        Pup {
            id: pup
            x: scene.pupX
            y: track.height - 17 - height
            width: 86
            height: 60
            pose: scene.pose

            // Two Woof! balloons, one after the other
            Repeater {
                id: woofs
                function play() { for (let i = 0; i < count; ++i) itemAt(i).pop() }
                model: [{ right: 2, top: 14, size: 12, delay: 0 }, { right: -54, top: 2, size: 13, delay: 450 }]
                Item {
                    id: balloon
                    required property var modelData
                    x: modelData.right - width
                    y: modelData.top
                    width: woofText.implicitWidth + 16
                    height: woofText.implicitHeight + 6
                    opacity: 0
                    transformOrigin: Item.Right
                    function pop() { popWait.duration = Math.max(1, modelData.delay); popUp.restart() }
                    Rectangle { anchors.fill: parent; radius: 10; color: "white" }
                    Rectangle {  // The tail, pointing at the pup
                        x: parent.width - 4; y: 6
                        width: 7; height: 7
                        rotation: 45
                        color: "white"
                    }
                    Text {
                        id: woofText
                        anchors.centerIn: parent
                        text: "Woof!"
                        color: "#1e2619"
                        font.bold: true
                        font.weight: Font.ExtraBold
                        font.pixelSize: balloon.modelData.size
                    }
                    SequentialAnimation {
                        id: popUp
                        PauseAnimation { id: popWait }
                        ScriptAction { script: { balloon.scale = 0.3; balloon.rotation = -10; balloon.opacity = 0; balloon.y = balloon.modelData.top } }
                        ParallelAnimation {
                            NumberAnimation { target: balloon; property: "opacity"; to: 1; duration: 180 }
                            NumberAnimation { target: balloon; property: "scale"; to: 1.18; duration: 180 }
                            NumberAnimation { target: balloon; property: "rotation"; to: 4; duration: 180 }
                        }
                        ParallelAnimation {
                            NumberAnimation { target: balloon; property: "scale"; to: 1; duration: 150 }
                            NumberAnimation { target: balloon; property: "rotation"; to: 0; duration: 150 }
                        }
                        PauseAnimation { duration: 870 }
                        ParallelAnimation {
                            NumberAnimation { target: balloon; property: "opacity"; to: 0; duration: 300 }
                            NumberAnimation { target: balloon; property: "y"; to: balloon.modelData.top - 6; duration: 300 }
                        }
                    }
                }
            }
            // Remove, when done: hearts float up
            Repeater {
                model: scene.removing && scene.ok ? [{ x: 60, delay: 0, size: 14 }, { x: 74, delay: 500, size: 11 }, { x: 50, delay: 1000, size: 12 }] : []
                Text {
                    id: heart
                    required property var modelData
                    text: "♥"
                    color: "#f2849a"
                    font.pixelSize: modelData.size
                    x: modelData.x
                    property real t: 0
                    y: -4 - 34 * t
                    opacity: t < 0.2 ? t / 0.2 : 1 - (t - 0.2) / 0.8
                    scale: 0.5 + 0.6 * t
                    SequentialAnimation on t {
                        loops: Animation.Infinite
                        PauseAnimation { duration: heart.modelData.delay }
                        NumberAnimation { from: 0; to: 1; duration: 1600; easing.type: Easing.OutQuad }
                    }
                }
            }
        }
    }

    Label {
        text: scene.hint
        color: palette.placeholderText
        font.pointSize: Application.font.pointSize - 1
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        textFormat: Text.PlainText
        Layout.fillWidth: true
        Layout.minimumHeight: implicitHeight
    }
}
