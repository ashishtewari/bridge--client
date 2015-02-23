import QtQuick 1.1

Rectangle {
    id: container

    property alias text: buttonLabel.text
    property int fontSize: 16
    property alias mouseEnabled: mouseArea.enabled
    property bool current: false

    signal clicked

    Rectangle {
        id: highlight
        radius: parent.radius
        border { color: "yellow"; width: 3 }
        visible: parent.current
        anchors.fill: parent
    }

    SystemPalette { id: activePalette }

    width: buttonLabel.width + 20; height: buttonLabel.height + 10
    smooth: true
    border { width: 1; color: Qt.darker(activePalette.button) }
    radius: 15
    color: activePalette.button

    gradient: Gradient {
        GradientStop {
            position: 0.0
            color: mouseArea.pressed ? activePalette.dark : activePalette.light
        }
        GradientStop { position: 1.0; color: activePalette.button }
    }

    MouseArea { id: mouseArea; anchors.fill: parent; onClicked: container.clicked() }

    Text {
        id: buttonLabel
        anchors.centerIn: container
        color: activePalette.buttonText
        font.pixelSize: parent.fontSize
    }
}
