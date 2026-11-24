import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCore

// Asks what to remove besides the package itself, then follows the removal in the same window.
// Settings and data stay unless the person ticks them. The person holds the box under the bag to remove.
// ask(name, choices: [{text, checked}], leftovers: [{kind, path, bytes, checkedByDefault}], icon); `accepted` gives the
// ticked choices (one bool each) and the chosen leftover paths. Whoever queues the removal then calls follow(id).
Window {
    id: window
    Shortcut { sequences: [StandardKey.Cancel]; onActivated: window.close() }  // Escape, as a QDialog
    property var store
    property var registry           // The main window: its jobWindows lists the window that follows each operation
    property string appName: ""
    property string icon: ""
    property var choices: []
    property var leftovers: []
    signal accepted(var options, var paths)

    property int jobId: 0
    property var job: ({})          // Set by the main window while this window follows the removal
    JobState { id: jobState; store: window.store; jobId: window.jobId; job: window.job }
    readonly property bool confirming: jobId === 0
    readonly property bool failed: jobState.failed
    onFailedChanged: if (failed) details.checked = true  // The output says why

    title: "Remove " + appName
    flags: Qt.Dialog
    modality: confirming ? Qt.WindowModal : Qt.NonModal
    color: palette.window
    width: 440
    readonly property int fitHeight: layout.implicitHeight + 28
    height: fitHeight
    minimumWidth: width
    maximumWidth: width
    minimumHeight: fitHeight
    maximumHeight: fitHeight

    function ask(name, offered, found, appIcon) {
        // A removal this window still follows gets its own window from now on
        if (jobId !== 0 && registry && registry.jobWindows[jobId] === window) delete registry.jobWindows[jobId]
        jobId = 0
        job = ({})
        appName = name
        icon = appIcon ?? ""
        choices = offered
        leftovers = found
        details.checked = false
        scene.active = false
        scene.active = true
        show(); raise(); requestActivate()
    }
    // The removal was queued as operation `id` (0: it was refused)
    function follow(id) {
        if (id <= 0) { close(); return }
        if (registry) registry.jobWindows[id] = window
        jobId = id
        job = registry ? registry.activity.find(a => a.id === id) ?? ({}) : ({})
    }
    function size(bytes) {
        const units = ["B", "KiB", "MiB", "GiB"]
        let value = bytes, unit = 0
        while (value >= 1024 && unit < units.length - 1) { value /= 1024; ++unit }
        return (unit === 0 ? value : value.toFixed(1)) + " " + units[unit]
    }
    function confirm() {
        const ticked = [], paths = []
        for (let i = 0; i < options.count; ++i) ticked.push(options.itemAt(i).checked)
        for (let i = 0; i < files.count; ++i) if (files.itemAt(i).checked) paths.push(window.leftovers[i].path)
        window.accepted(ticked, paths)
    }
    property real freed: 0          // Bytes of the ticked leftovers
    function countFreed() {
        let total = 0
        for (let i = 0; i < files.count; ++i) if (files.itemAt(i)?.checked) total += window.leftovers[i].bytes
        freed = total
    }
    readonly property string home: StandardPaths.writableLocation(StandardPaths.HomeLocation).toString().replace("file://", "")

    ColumnLayout {
        id: layout
        x: 16
        y: 14
        width: window.width - 32
        spacing: 12

        Loader {
            id: scene
            Layout.fillWidth: true
            sourceComponent: Component { OpScene {
                removing: true
                icon: window.icon
                confirming: window.confirming
                holdNote: window.freed > 0 ? "frees " + window.size(window.freed) + " of files" : ""
                progress: jobState.progress
                ok: jobState.ok
                failed: jobState.failed
                heading: window.confirming ? "Remove " + window.appName + "?"
                    : jobState.ok ? window.appName + " removed" : jobState.failed ? window.appName + " is still installed" : "Removing " + window.appName
                subheading: window.confirming ? "" : jobState.failed ? "It did not finish. Open the details to see why."
                    : jobState.ok ? "Removed from this computer" : jobState.line
                hint: window.confirming ? "Or focus the box and press Enter"
                    : jobState.ok ? "Settings and data stay unless you ticked them"
                    : jobState.failed ? "Stopped at " + jobState.steps[jobState.step]
                    : jobState.line === "" ? "Starting…" : Math.round(jobState.progress * 100) + "%"
                onConfirmed: window.confirm()
            } }
        }

        // What else to remove; folds away once the removal starts
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: window.confirming ? choicesColumn.implicitHeight : 0
            visible: Layout.preferredHeight > 0
            opacity: window.confirming ? 1 : 0
            clip: true
            Behavior on Layout.preferredHeight { NumberAnimation { duration: 500; easing.type: Easing.InOutCubic } }
            Behavior on opacity { NumberAnimation { duration: 350 } }
            ColumnLayout {
                id: choicesColumn
                width: parent.width
                spacing: 6
                Repeater {
                    id: options
                    model: window.choices
                    CheckBox { required property var modelData; text: modelData.text; checked: modelData.checked; Layout.fillWidth: true }
                }
                Label {
                    visible: window.leftovers.length > 0
                    text: "Caches are rebuilt on demand and are selected. Settings and data may hold your documents or accounts, so they stay unless you select them."
                    color: palette.placeholderText
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                }
                Repeater {
                    id: files
                    model: window.leftovers
                    CheckBox {
                        required property var modelData
                        text: modelData.kind + " · " + (modelData.path.startsWith(window.home) ? "~" + modelData.path.slice(window.home.length) : modelData.path) + " · " + window.size(modelData.bytes)
                        checked: modelData.checkedByDefault
                        onCheckedChanged: window.countFreed()
                        Component.onCompleted: window.countFreed()
                        Layout.fillWidth: true
                    }
                }
            }
        }

        RowLayout {
            ToolButton {
                id: details
                visible: !window.confirming
                checkable: true
                text: checked ? "Hide details" : "Show details"
                icon.name: checked ? "arrow-down" : "arrow-right"
                display: AbstractButton.TextBesideIcon
            }
            Item { Layout.fillWidth: true }
            Button {
                text: window.confirming ? "Cancel" : jobState.ended ? "Close" : "Hide"
                ToolTip.visible: hovered && !window.confirming && !jobState.ended
                ToolTip.text: "The removal keeps running; progress stays in Activity"
                onClicked: window.close()
            }
        }
        ScrollView {
            visible: details.checked && !window.confirming
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            TextArea {
                readOnly: true
                text: jobState.log
                font.family: "monospace"
                wrapMode: TextEdit.NoWrap
                onTextChanged: cursorPosition = length
            }
        }
    }
}
