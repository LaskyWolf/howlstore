import QtQuick

// The pup's head, shared by every pose. Origin = the neck. The dark ear is the far one; the green ear is in front.
Item {
    id: head
    property bool sleep: false
    property real mouth: 0      // 0 closed, 1 open
    property real earFront: 0   // degrees, around the ear's base
    property real earBack: 0
    Draw { id: draw }

    Item {
        transform: Rotation { origin.x: 11.25; origin.y: -14; angle: head.earBack }
        Blob { d: "M15.5 -17 L11 -30 Q9 -31.5 7.5 -28.5 L7 -14 Z"; fill: draw.dark }
    }
    Blob { d: draw.ellipse(4, -11, 13, 12); fill: draw.body }
    Item {
        transform: Rotation { origin.x: 0.5; origin.y: -15; angle: head.earFront }
        Blob { d: "M-7 -15 L-4.5 -35 Q-1.5 -37.5 1 -34.5 L8 -19 Z"; fill: draw.body }
        Blob { d: "M-3.5 -18 L-2.2 -31 L4 -20 Z"; fill: draw.innerEar }
    }
    Blob { d: draw.ellipse(16, -6, 9, 6.5); fill: draw.cream }
    Item {
        opacity: head.mouth
        Blob { d: "M14 -2 Q18.5 6 23 -2 Z"; fill: "#7a1f1f" }
        Blob { d: draw.ellipse(18.5, 1.8, 2.4, 1.6); fill: "#f2849a" }
    }
    Blob { d: draw.ellipse(24, -8.5, 3.4, 2.6); fill: draw.nose }
    Blob { d: "M15 -1.5 Q18.5 1 22 -1.5"; stroke: draw.nose; strokeWidth: 1.6 }
    Blob { visible: head.sleep; d: "M5 -13 Q8 -10.5 11 -13"; stroke: draw.nose; strokeWidth: 1.6 }
    Blob { visible: !head.sleep; d: draw.circle(8.5, -14, 2.5); fill: draw.nose }
    Blob { visible: !head.sleep; d: draw.circle(9.4, -14.9, 0.9); fill: "white" }
    Blob { d: "M-9 -1 Q0 5 9 1"; stroke: draw.collar; strokeWidth: 4 }
    Blob { d: draw.circle(1, 4.5, 2.6); fill: draw.tag }
}
