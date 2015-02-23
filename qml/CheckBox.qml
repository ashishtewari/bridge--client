import QtQuick 1.1

Item {
    id: checkbox
    property bool checked: false
    property string text
    property string fontColor: "white"
    property int fontSize: 12
    width: childrenRect.width
    height: childrenRect.height

    Row {
        id: content

        Image {
            id: checkImg
            source: checkbox.checked ? "images/checkbox_full.png" : "images/checkbox_empty.png"
        }
        Text {
            text: checkbox.text
            color: checkbox.fontColor
            font.pixelSize: checkbox.fontSize
            anchors.verticalCenter: checkImg.verticalCenter
        }
    }

    MouseArea {
        anchors.fill: content
        onClicked: checked = !checked;
    }
}
