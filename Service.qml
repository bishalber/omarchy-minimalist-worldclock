pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

Item {
  id: root

  readonly property string pluginDir: Quickshell.env("HOME") + "/.config/omarchy/plugins/bishu.minimalist-worldclock"

  // Major cities: name, IANA timezone, latitude, longitude (equirectangular projection).
  readonly property var cities: [
    { name: "Los Angeles", tz: "America/Los_Angeles", lat: 34.0522, lon: -118.2437 },
    { name: "New York",    tz: "America/New_York",    lat: 40.7128, lon: -74.0060 },
    { name: "Sao Paulo",   tz: "America/Sao_Paulo",    lat: -23.5505, lon: -46.6333 },
    { name: "London",      tz: "Europe/London",        lat: 51.5074, lon: -0.1278 },
    { name: "Paris",       tz: "Europe/Paris",         lat: 48.8566, lon: 2.3522 },
    { name: "Madrid",      tz: "Europe/Madrid",        lat: 40.4168, lon: -3.7038 },
    { name: "Helsinki",    tz: "Europe/Helsinki",      lat: 60.1699, lon: 24.9384 },
    { name: "Cairo",       tz: "Africa/Cairo",         lat: 30.0444, lon: 31.2357 },
    { name: "Johannesburg",tz: "Africa/Johannesburg",  lat: -26.2041, lon: 28.0473 },
    { name: "Moscow",      tz: "Europe/Moscow",        lat: 55.7558, lon: 37.6173 },
    { name: "Dubai",       tz: "Asia/Dubai",           lat: 25.2048, lon: 55.2708 },
    { name: "New Delhi",   tz: "Asia/Kolkata",         lat: 28.6139, lon: 77.2090 },
    { name: "Singapore",   tz: "Asia/Singapore",       lat: 1.3521, lon: 103.8198 },
    { name: "Hong Kong",   tz: "Asia/Hong_Kong",       lat: 22.3193, lon: 114.1694 },
    { name: "Beijing",     tz: "Asia/Shanghai",        lat: 39.9042, lon: 116.4074 },
    { name: "Tokyo",       tz: "Asia/Tokyo",           lat: 35.6762, lon: 139.6503 },
    { name: "Sydney",      tz: "Australia/Sydney",     lat: -33.8688, lon: 151.2093 }
  ]

  property var cityTimes: ({})

  function buildTzScript() {
    var parts = []
    for (var i = 0; i < root.cities.length; i++) {
      parts.push("printf '%s=%s|' " + i + " \"$(TZ=" + root.cities[i].tz + " date +%H:%M:%S)\"")
    }
    return parts.join("; ")
  }

  function applyTimes(line) {
    var next = {}
    var entries = line.split("|")
    for (var i = 0; i < entries.length; i++) {
      var entry = entries[i]
      if (entry.length === 0) continue
      var eq = entry.indexOf("=")
      if (eq === -1) continue
      var idx = entry.substring(0, eq)
      var time = entry.substring(eq + 1)
      next[idx] = time
    }
    root.cityTimes = next
  }

  function timeFor(index) {
    return root.cityTimes[String(index)] || "--:--:--"
  }

  Process {
    id: tzProc
    command: ["bash", "-c", root.buildTzScript()]
    stdout: SplitParser {
      onRead: function(data) { root.applyTimes(data) }
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: if (!tzProc.running) tzProc.running = true
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: panel
      required property var modelData

      screen: modelData
      color: "transparent"
      anchors { top: true; bottom: true; left: true; right: true }
      exclusionMode: ExclusionMode.Ignore

      WlrLayershell.namespace: "bishu-minimalist-worldclock"
      WlrLayershell.layer: WlrLayer.Background
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

      Rectangle {
        id: ocean
        anchors.fill: parent
        color: "#0a0f1e"
      }

      Image {
        id: mapImage
        anchors.fill: parent
        source: "file://" + root.pluginDir + "/assets/world-map.png"
        fillMode: Image.PreserveAspectFit
        smooth: true
        asynchronous: true
      }

      // Live-updating local time and date for this screen's system clock, top-left.
      Column {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 48
        spacing: 4

        Text {
          text: Qt.formatTime(clock.date, "HH:mm:ss")
          color: "#eef3fb"
          font.pixelSize: 42
          font.family: "sans-serif"
          font.weight: Font.Light
        }
        Text {
          text: Qt.formatDate(clock.date, "dddd, d MMMM yyyy")
          color: "#8fa0c0"
          font.pixelSize: 16
          font.family: "sans-serif"
        }
      }

      SystemClock {
        id: clock
        precision: SystemClock.Seconds
      }

      Repeater {
        model: root.cities

        Item {
          id: marker
          required property var modelData
          required property int index

          readonly property real mapOffsetX: mapImage.x + (mapImage.width - mapImage.paintedWidth) / 2
          readonly property real mapOffsetY: mapImage.y + (mapImage.height - mapImage.paintedHeight) / 2

          readonly property real px: mapOffsetX + (modelData.lon + 180) / 360 * mapImage.paintedWidth
          readonly property real py: mapOffsetY + (90 - modelData.lat) / 180 * mapImage.paintedHeight

          x: px
          y: py
          width: 1
          height: 1

          Rectangle {
            id: dot
            width: 7
            height: 7
            radius: 4
            color: "#7fd9c4"
            anchors.centerIn: parent

            Rectangle {
              anchors.centerIn: parent
              width: 16
              height: 16
              radius: 8
              color: "#7fd9c4"
              opacity: 0.18
            }
          }

          Column {
            anchors.top: dot.bottom
            anchors.topMargin: 4
            anchors.horizontalCenter: dot.horizontalCenter
            spacing: 1

            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: marker.modelData.name
              color: "#eef3fb"
              font.pixelSize: 12
              font.family: "sans-serif"
              font.weight: Font.DemiBold
              style: Text.Outline
              styleColor: "#0a0f1e"
            }
            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: root.timeFor(marker.index)
              color: "#7fd9c4"
              font.pixelSize: 12
              font.family: "monospace"
              style: Text.Outline
              styleColor: "#0a0f1e"
            }
          }
        }
      }
    }
  }
}
