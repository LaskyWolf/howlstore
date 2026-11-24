import QtQuick

// Six green paws that burst out of one point. play() fires them.
Item {
    id: sparks
    function play(delay) { for (let i = 0; i < burst.count; ++i) burst.itemAt(i).fire(delay + i * 50) }
    Draw { id: draw }
    Repeater {
        id: burst
        model: [[-80, -50, -40], [78, -46, 30], [-46, -92, -20], [50, -96, 25], [0, -110, 0], [-96, -6, -60]]
        Item {
            id: spark
            required property var modelData
            property real t: 0
            function fire(delay) { wait.duration = Math.max(1, delay); flight.restart() }
            opacity: t <= 0 ? 0 : t < 0.3 ? t / 0.3 : (1 - t) / 0.7
            x: -7 + modelData[0] * t
            y: -7 + 20 + (modelData[1] - 20) * t
            width: 14
            height: 14
            rotation: modelData[2] * t
            scale: 0.3 + 0.7 * t
            SequentialAnimation {
                id: flight
                PauseAnimation { id: wait }
                NumberAnimation { target: spark; property: "t"; from: 0; to: 1; duration: 1000; easing.type: Easing.OutCubic }
                ScriptAction { script: spark.t = 0 }
            }
            Item {
                scale: 14 / 24
                transformOrigin: Item.TopLeft
                Blob { d: draw.paw; fill: draw.body }
            }
        }
    }
}
