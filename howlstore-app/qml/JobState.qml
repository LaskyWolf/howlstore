import QtQuick

// What one operation's window shows: its output, its current line and how far it got, from store.activity and the log.
QtObject {
    id: state
    property var store
    property int jobId: 0
    property var job: ({})          // The operation's entry of store.activity
    readonly property bool ended: job.state === "done" || job.state === "failed"
    readonly property bool ok: job.state === "done"
    readonly property bool failed: job.state === "failed"
    readonly property var steps: job.steps && job.steps.length ? job.steps : ["Prepare", "Run"]
    readonly property int step: ok ? steps.length : Math.min(job.step ?? 0, steps.length - 1)
    property string log: ""
    property real fraction: 0       // The active step's own progress: the last percent in the output
    property string line: ""        // The last line of output, without its ==> or -> marker
    // Overall progress from 0 to 1: the steps done, plus the active step's percent, or a little while it is unknown.
    // Only a finished operation reaches 1.
    readonly property real progress: ok ? 1 : Math.min(0.97, (step + (fraction > 0 ? fraction : 0.15)) / steps.length)

    function refresh() {
        if (!store || jobId === 0) return  // createObject can set job before store
        log = clean(store.jobLog(jobId))
        const lines = log.split(/[\n\r]/).map(l => l.trim()).filter(l => l !== "")
        let percent = 0
        for (const text of lines) {
            const found = text.match(/(\d{1,3})%/)
            if (found && Number(found[1]) <= 100) percent = Number(found[1]) / 100
        }
        fraction = percent
        const last = lines.length ? lines[lines.length - 1] : ""
        line = last.startsWith("==>") ? last.slice(3).trim() : last.startsWith("->") ? last.slice(2).trim() : last
    }
    function clean(text) { return text.replace(/\x1b\[[0-9;?]*[A-Za-z]/g, "") }
    onJobChanged: refresh()
    onStoreChanged: refresh()
    onJobIdChanged: refresh()
}
