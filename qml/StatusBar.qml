import QtQuick 1.1

Item {
    id: bar
    height: 32

    property int round: 0
    property int boardNo
    property alias text: statusText.text
    property alias showText: statusText.visible
    property alias showNewGameBtn: newGameBtn.visible
    property alias showCloseBtn: closeBtn.visible
    property alias bgColor: backgrounds.currentColor
    signal settingsTriggered
    signal newGame
    signal closed

    Rectangle {
        id: background
        color: "black"
        opacity: 0.4
        anchors.fill: parent
    }

    Row {
        id: backgrounds
        anchors { left: parent.left; leftMargin: 20 }
        height: parent.height
        property string currentColor: "green"
        spacing: 2

        Repeater {
            model: ListModel {
                ListElement { color: "green" }
                ListElement { color: "brown" }
                ListElement { color: "red" }
            }
            Image {
                source: "images/backgrounds/"+color+"_thumb.png"
                height: parent.height
                fillMode: Image.PreserveAspectFit
                smooth: true
                MouseArea {
                    anchors.fill: parent
                    onClicked: backgrounds.currentColor=color
                }
            }
        }
    }

    Text {
        id: roundBoard
        text: "Round: "+parent.round + ", Board: "+parent.boardNo
        color: "white"
        anchors {
            verticalCenter: parent.verticalCenter
            left: backgrounds.right
            leftMargin: 10
        }
        font.pixelSize: 14
        visible: parent.round>0
    }

    Text {
        id: statusText
        color: "white"
        anchors.centerIn: parent
        font.pixelSize: 14
    }

    Row {
        anchors.centerIn: parent
        Button {
            id: newGameBtn
            text: "New Game"
            onClicked: bar.newGame()
        }
        Button {
            id: closeBtn
            text: "Close"
            onClicked: bar.closed()
        }
    }

    Rectangle {
        id: iconHighlight
        color: "white"
        opacity: 0.5
        radius: 5
        anchors.fill: settingsIcon
        visible: mouseArea.pressed
    }

    Image {
        id: settingsIcon
        source: "images/settings.png"
        anchors {
            right: parent.right
            rightMargin: 10
            bottom: parent.bottom
            bottomMargin: 5
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: bar.settingsTriggered()
        }
    }
}
