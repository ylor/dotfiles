import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Item {
  id: root

  property bool stayAwake: false

  IdleMonitor {
    id: idleMonitor
    enabled: !root.stayAwake
    timeout: 3600
    respectInhibitors: true
    onIsIdleChanged: {
      if (isIdle) suspendProcess.running = true
      else retryTimer.stop()
    }
  }

  // Fails while a logind idle lock is held; try again each minute while still idle.
  Process {
    id: suspendProcess
    command: ["bash", "-c",
      'test -z "$(systemd-inhibit --list --what=idle --mode=block --no-legend)" && systemctl suspend']
    onExited: function(exitCode) {
      if (exitCode !== 0 && idleMonitor.isIdle) retryTimer.restart()
    }
  }

  Timer {
    id: retryTimer
    interval: 60000
    onTriggered: suspendProcess.running = true
  }

  Process {
    id: stayAwakeProbe
    running: true
    command: ["omarchy-toggle-idle", "status"]
    stdout: StdioCollector {
      onStreamFinished: root.stayAwake = JSON.parse(text).enabled
    }
    onExited: stayAwakeWatcher.reload()
  }

  FileView {
    id: stayAwakeWatcher
    path: Quickshell.env("HOME") + "/.local/state/omarchy/indicators"
    watchChanges: true
    printErrors: false
    onFileChanged: stayAwakeProbe.running = true
  }
}
