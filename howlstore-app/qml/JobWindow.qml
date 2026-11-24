import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Progress of a package operation without a terminal. System Update shows the sleeping pup under a sunrise; removals
// show the pup sliding out; everything else shows the pup walking to the tote bag. The raw output is one click away.
// While the operation runs, closing the window only hides it.
Window {
    id: window
    Shortcut { sequences: [StandardKey.Cancel]; onActivated: window.close() }  // Escape, as a QDialog
    property var store
    property var catalog            // Opens an installed app
    property int jobId: 0
    property var job: ({})          // The operation's entry of store.activity
    property var meta: ({})         // From whoever queued it: {icon, key}

    JobState { id: jobState; store: window.store; jobId: window.jobId; job: window.job }
    readonly property string kind: job.title === "System Update" ? "update" : String(job.title ?? "").startsWith("Remove ") ? "remove" : "install"
    readonly property string verb: String(job.title ?? "").match(/^(Install|Reinstall) /)?.[1] ?? ""
    readonly property string name: String(job.title ?? "").replace(/^(Install|Reinstall|Remove) /, "").replace(/ from the AUR$/, "")
    readonly property string percent: Math.round(jobState.progress * 100) + "%"

    title: job.title ?? ""
    flags: Qt.Dialog
    color: palette.window
    width: kind === "update" ? 560 : 440
    readonly property int fitHeight: layout.implicitHeight + 28
    height: fitHeight
    minimumWidth: width
    maximumWidth: width
    minimumHeight: fitHeight
    maximumHeight: fitHeight
    readonly property bool failed: jobState.failed
    onFailedChanged: if (failed) details.checked = true  // The output says why

    ColumnLayout {
        id: layout
        x: 16
        y: 14
        width: window.width - 32
        spacing: 12

        Loader {
            Layout.fillWidth: true
            sourceComponent: window.kind === "update" ? sunrise : walk
        }
        Component {
            id: sunrise
            UpdateScene {
                steps: jobState.steps
                step: jobState.step
                fraction: jobState.fraction
                progress: jobState.progress
                ok: jobState.ok
                failed: jobState.failed
                line: jobState.line
            }
        }
        Component {
            id: walk
            OpScene {
                removing: window.kind === "remove"
                icon: window.meta.icon ?? ""
                progress: jobState.progress
                ok: jobState.ok
                failed: jobState.failed
                heading: window.kind === "remove"
                    ? (jobState.ok ? window.name + " removed" : jobState.failed ? window.name + " is still installed" : "Removing " + window.name)
                    : window.verb !== ""
                    ? (jobState.ok ? window.name + " is ready" : jobState.failed ? window.name + " was not installed"
                       : (window.verb === "Install" ? "Installing " : "Reinstalling ") + window.name)
                    : (jobState.ok ? window.title + " finished" : jobState.failed ? window.title + " did not finish" : window.title)
                subheading: jobState.failed ? "It did not finish. Open the details to see why."
                    : jobState.ok ? (window.kind === "remove" ? "Removed from this computer"
                                  : window.verb !== "" ? (window.meta.key ? "Find it in the app menu, or open it now" : "Find it in the app menu") : "")
                    : jobState.line
                hint: jobState.ok ? (window.kind === "remove" ? "Settings and data stay unless you ticked them" : "All " + jobState.steps.length + " steps done")
                    : jobState.failed ? "Stopped at " + jobState.steps[jobState.step]
                    : jobState.steps[jobState.step] + " · step " + (jobState.step + 1) + " of " + jobState.steps.length + " · " + window.percent
            }
        }

        RowLayout {
            ToolButton {
                id: details
                checkable: true
                text: checked ? "Hide details" : "Show details"
                icon.name: checked ? "arrow-down" : "arrow-right"
                display: AbstractButton.TextBesideIcon
            }
            Item { Layout.fillWidth: true }
            Button {
                text: jobState.ended ? "Close" : "Hide"
                ToolTip.visible: hovered && !jobState.ended
                ToolTip.text: "The operation keeps running; progress stays in Activity"
                onClicked: window.close()
            }
            Button {
                visible: jobState.ok && window.kind === "install" && window.verb !== "" && !!window.meta.key && !!window.catalog
                text: "Open"
                highlighted: true
                onClicked: {
                    const problem = window.catalog.launch(window.meta.key)
                    if (problem === "") window.close()
                }
            }
        }
        ScrollView {
            visible: details.checked
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
