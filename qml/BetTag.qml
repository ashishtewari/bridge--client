import QtQuick 1.1

Item {
    id: tag
    width: img.paintedWidth
    height: img.paintedHeight
    property alias source: img.source
    property alias mouseEnabled: mArea.enabled
    signal clicked

    Rectangle {
        id: bg
        color: "white"
        opacity: mArea.pressed ? 0.1 : 0.3
        anchors.fill: parent
        radius: 5
    }

    Image {
        id: img
    }

    MouseArea {
        id: mArea
        anchors.fill: parent
        onClicked: parent.clicked()
    }
}
