import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: cBg

    // Palette from theme.conf, with literal fallbacks so a missing or
    // unreadable config still renders something usable rather than black.
    readonly property color cBg:      config.colorBg      || "#111826"
    readonly property color cBgAlt:   config.colorBgAlt   || "#182545"
    readonly property color cFg:      config.colorFg      || "#dddddd"
    readonly property color cAccent:  config.colorAccent  || "#82dccc"
    readonly property color cAccent2: config.colorAccent2 || "#01ccff"
    readonly property color cMuted:   config.colorMuted   || "#798bb2"
    readonly property color cCrit:    config.colorCrit    || "#ff5555"
    readonly property string fontFam: config.fontFamily   || "JetBrainsMono Nerd Font"

    property string currentUser: userModel.lastUser || ""
    property int    sessionIndex: sessionModel.lastIndex
    property int    userIndex: userModel.lastIndex

    // Hidden ComboBoxes exist purely so Qt resolves the models' name role and
    // row order for us via textAt(). Reading the roles by hand got the order
    // wrong, which would have logged into plain Hyprland instead of the
    // uwsm-managed session -- and without uwsm there is no
    // graphical-session.target, so waybar and hyprpaper never start.
    ComboBox {
        id: sessionData
        model: sessionModel
        textRole: "name"
        visible: false
        currentIndex: root.sessionIndex
    }

    ComboBox {
        id: userData
        model: userModel
        textRole: "name"
        visible: false
        currentIndex: root.userIndex
    }

    // ---------------------------------------------------------- background --
    // Blurred and dimmed to match hyprlock's background block, so the greeter
    // and the lock screen read as the same surface.
    Image {
        id: bgImage
        anchors.fill: parent
        source: config.background || ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        visible: false
    }

    MultiEffect {
        anchors.fill: parent
        source: bgImage
        blurEnabled: true
        blur: Number(config.blurAmount) || 0.75
        blurMax: 64
        autoPaddingEnabled: false
    }

    Rectangle {
        anchors.fill: parent
        color: cBg
        opacity: Number(config.dimOpacity) || 0.55
    }

    // --------------------------------------------------------------- clock --
    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var d = new Date()
            clock.text = Qt.formatDateTime(d, "HH:mm")
            dateLabel.text = Qt.formatDateTime(d, "dddd, dd MMMM")
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 0

        Text {
            id: clock
            Layout.alignment: Qt.AlignHCenter
            color: cFg
            font.family: fontFam
            font.pixelSize: Number(config.clockSize) || 110
            font.weight: Font.ExtraBold
            text: "--:--"
        }

        Text {
            id: dateLabel
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 4
            color: cAccent
            font.family: fontFam
            font.pixelSize: Number(config.dateSize) || 22
            text: ""
        }

        // ------------------------------------------------------ password ----
        Rectangle {
            id: field
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 56
            width: 320
            height: 52
            radius: 10
            color: cBgAlt
            border.width: 2
            border.color: passwordField.activeFocus ? cAccent : cBgAlt

            Behavior on border.color { ColorAnimation { duration: 150 } }

            TextInput {
                id: passwordField
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                verticalAlignment: TextInput.AlignVCenter
                horizontalAlignment: TextInput.AlignHCenter
                echoMode: TextInput.Password
                passwordCharacter: "●"
                passwordMaskDelay: 0
                color: cFg
                font.family: fontFam
                font.pixelSize: 16
                focus: true
                enabled: !busy.running
                selectByMouse: true

                onAccepted: root.doLogin()

                Text {
                    anchors.centerIn: parent
                    visible: passwordField.text.length === 0
                    text: "Password…"
                    color: cMuted
                    font.family: fontFam
                    font.pixelSize: 16
                }
            }

            BusyIndicator {
                id: busy
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                height: 26
                width: 26
                running: false
            }
        }

        Text {
            id: errorLabel
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 12
            color: cCrit
            font.family: fontFam
            font.pixelSize: 14
            text: ""
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 8
            color: cMuted
            font.family: fontFam
            font.pixelSize: 14
            text: root.currentUser
        }
    }

    function doLogin() {
        if (passwordField.text.length === 0)
            return
        errorLabel.text = ""
        busy.running = true
        sddm.login(root.currentUser, passwordField.text, root.sessionIndex)
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            busy.running = false
            errorLabel.text = "Incorrect password"
            passwordField.text = ""
            passwordField.forceActiveFocus()
        }
        function onLoginSucceeded() {
            busy.running = false
        }
    }

    // ------------------------------------------------------- bottom bar -----
    RowLayout {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 28
        spacing: 14

        // Click to cycle. A styled ComboBox would need the Basic Controls style
        // to be active, which the greeter does not guarantee, so the dropdown
        // would render in whatever theme Qt picked and ignore these colours.
        Text {
            visible: sessionData.count > 0
            text: "󰧨  " + sessionData.textAt(root.sessionIndex)
            color: sessionMouse.containsMouse ? cAccent2 : cMuted
            font.family: fontFam
            font.pixelSize: 13

            Behavior on color { ColorAnimation { duration: 150 } }

            MouseArea {
                id: sessionMouse
                anchors.fill: parent
                anchors.margins: -8
                hoverEnabled: true
                enabled: sessionData.count > 1
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: root.sessionIndex =
                    (root.sessionIndex + 1) % sessionData.count
            }
        }

        Text {
            visible: userData.count > 1
            text: "󰀄  " + userData.textAt(root.userIndex)
            color: userMouse.containsMouse ? cAccent2 : cMuted
            font.family: fontFam
            font.pixelSize: 13

            Behavior on color { ColorAnimation { duration: 150 } }

            MouseArea {
                id: userMouse
                anchors.fill: parent
                anchors.margins: -8
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.userIndex = (root.userIndex + 1) % userData.count
                    root.currentUser = userData.textAt(root.userIndex)
                }
            }
        }
    }

    RowLayout {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 28
        spacing: 18

        Repeater {
            model: [
                { glyph: "", action: "shutdown", enabled: sddm.canPowerOff },
                { glyph: "", action: "reboot",   enabled: sddm.canReboot },
                { glyph: "", action: "suspend",  enabled: sddm.canSuspend }
            ]

            delegate: Text {
                text: modelData.glyph
                visible: modelData.enabled
                color: mouse.containsMouse ? cAccent2 : cMuted
                font.family: fontFam
                font.pixelSize: 20

                Behavior on color { ColorAnimation { duration: 150 } }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    anchors.margins: -8
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (modelData.action === "shutdown") sddm.powerOff()
                        else if (modelData.action === "reboot") sddm.reboot()
                        else sddm.suspend()
                    }
                }
            }
        }
    }

    Component.onCompleted: passwordField.forceActiveFocus()
}
