import QtQuick

// The pup curled up asleep, drawn in a 130 × 76 box: the same head with closed eyes, breathing slowly.
Item {
    id: sleepy
    implicitWidth: 130
    implicitHeight: 76
    Draw { id: draw }
    property real breath: 1
    SequentialAnimation on breath {
        loops: Animation.Infinite
        running: sleepy.visible
        NumberAnimation { from: 1; to: 1.06; duration: 1600; easing.type: Easing.InOutSine }
        NumberAnimation { from: 1.06; to: 1; duration: 1600; easing.type: Easing.InOutSine }
    }
    Item {
        width: 130
        height: 76
        transformOrigin: Item.TopLeft
        scale: sleepy.width / 130
        Item {
            transform: Scale { origin.x: 65; origin.y: 74; yScale: sleepy.breath }
            Blob { d: "M16 62 C10 72 30 74 48 72"; stroke: draw.body; strokeWidth: 6.5 }
            Blob { d: "M28 62 C30 42 92 42 94 60"; stroke: draw.body; strokeWidth: 24 }
            Blob { d: "M66 58 L100 66.5"; stroke: draw.body; strokeWidth: 9 }
            Blob { d: draw.ellipse(44, 61.5, 7, 3.6, -20); fill: draw.cream }
            Blob { d: draw.ellipse(104, 66.5, 7, 4); fill: draw.cream }
            Item {
                x: 86
                y: 60
                rotation: 10
                PupHead { sleep: true }
            }
        }
    }
}
