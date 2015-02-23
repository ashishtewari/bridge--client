import QtQuick 1.1
import "logic.js" as Logic

Item {
    id: box
    property bool enabled: true
    signal playerbid(int bidNo, int suit, string special)

    // standard=2; modern=1
    property int choice: 2

    Rectangle {
        id: background
        color: "white"
        opacity: 0.15
        radius: 8
        anchors.fill: parent
        Behavior on height { NumberAnimation { duration: 200 } }
    }

    Grid {
        id: grid
        visible: choice==2
        rows: 5
        columns: 7
        spacing: 3
        anchors {
            left: parent.left
            right: passBtn.left
            top: parent.top
            bottom: parent.bottom
            margins: 5
        }
        property int currentIndex: -1
        Repeater {
            model: 35
            BidButton {
                width: (grid.width-grid.spacing*6)/7
                height: (grid.height-grid.spacing*4)/5
                bidNo: index%7+1
                bidSuit: Math.floor(index/7)
                mouseEnabled: box.enabled
                current: grid.currentIndex==index
                onClicked: {
                    if (current) {
                        grid.currentIndex = -1;
                        statusBar.text = "";
                        box.playerbid(bidNo, bidSuit, "");
                    } else {
                        grid.currentIndex = index;
                        statusBar.text = "Tap on the bid again to confirm the bid";
                    }
                }
            }
        }
    }

    property int currentSpecial: -1

    Button {
        id: passBtn
        visible: choice==2
        text: "<font color=\"green\">Pass</font>"
        radius: 7
        fontSize: 20
        anchors {
            top: parent.top
            topMargin: 5
            right: parent.right
            rightMargin: 5
        }
        width: 75
        mouseEnabled: box.enabled
        current: grid.currentIndex<0 && currentSpecial==0
        onClicked: toggleCurrentSpecial(current, 0);
    }

    Button {
        id: xBtn
        visible: choice==2
        text: "<font color=\"blue\">X</font>"
        radius: 7
        fontSize: 20
        anchors {
            top: passBtn.bottom
            topMargin: 5
            right: xxBtn.left
            rightMargin: 5
        }
        width: (passBtn.width-5)/2
        mouseEnabled: box.enabled
        current: grid.currentIndex<0 && currentSpecial==1
        onClicked: toggleCurrentSpecial(current, 1);
    }

    Button {
        id: xxBtn
        visible: choice==2
        text: "<font color=\"red\">XX</font>"
        radius: 7
        fontSize: 20
        anchors {
            top: passBtn.bottom
            topMargin: 5
            right: parent.right
            rightMargin: 5
        }
        width: (passBtn.width-5)/2
        mouseEnabled: box.enabled
        current: grid.currentIndex<0 && currentSpecial==2
        onClicked: toggleCurrentSpecial(current, 2);
    }

    function toggleCurrentSpecial(current, index) {
        if (current) {
            currentSpecial = -1;
            bidForIndex(index);
        } else {
            grid.currentIndex = -1;
            currentSpecial = index;
        }
    }

    function bidForIndex(index) {
        var bidStr = ["pass", "x", "xx"][index];
        box.playerbid(0, 0, bidStr);
    }

    BetTag {
        id: pass
        source: "images/bet_tags/pass.png"
        visible: choice==1
        mouseEnabled: box.enabled
        anchors {
            top: parent.top
            topMargin: 5
            left: parent.left
            leftMargin: 5
        }
        onClicked: box.playerbid(0,0,"pass");
    }

    BetTag {
        id: x
        source: "images/bet_tags/X.png"
        visible: choice==1
        mouseEnabled: box.enabled
        anchors {
            top: parent.top
            topMargin: 5
            right: xx.left
            rightMargin: 5
        }
        onClicked: box.playerbid(0,0,"x");
    }

    BetTag {
        id: xx
        source: "images/bet_tags/XX.png"
        visible: choice==1
        mouseEnabled: box.enabled
        anchors {
            top: parent.top
            topMargin: 5
            right: parent.right
            rightMargin: 5
        }
        onClicked: box.playerbid(0,0,"xx");
    }

    Row {
        id: bidNos
        // decrease itemSize to prevent suits from going inexpanded when taking mouse over to them
        property int itemSize: 30
        property int currentIndex: -1
        property int lastIndex: -1
        onCurrentIndexChanged: {
            if (currentIndex!=-1) lastIndex = currentIndex;
        }

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 60
        }
        height: itemSize
        width: itemSize*7 + spacing*6
        visible: choice==1

        Repeater {
            model: 7

            Image {
                source: "images/bet_tags/Bet_Tag_"+(index+1)+".png"

                MouseArea {
                    anchors.fill: parent
                    enabled: box.enabled
                    onClicked: {
                        if (index == bidNos.currentIndex) {
                            bidSuits.expanded = false;
                            bidNos.currentIndex = -1;
                        } else {
                            bidSuits.expanded = true;
                            bidNos.currentIndex = index;
                        }
                    }
                }
            }
        }
    }

    // gloabl x position of the current bidNos item
    property real globalX: mapFromItem(bidNos, bidNos.lastIndex*bidNos.itemSize, 0).x;

    Rectangle {
        id: suitsBg
        color: "white"
        opacity: 0.6
        anchors.fill: bidSuits
        radius: 5
        visible: choice==1
    }

    Row {
        id: bidSuits
        property int itemSize: 27
        property bool expanded: false

        x: globalX + (bidNos.itemSize-width)/2
        y: bidNos.y+bidNos.height
        height: expanded ? itemSize : 0
        clip: true
        visible: choice==1

        Repeater {
            id: rep
            model: 5

            Item {
                width: bidSuits.itemSize
                height: bidSuits.itemSize

                Image {
                    id: img
                    source: index<4 ? "images/suits/"+["C","D","H","S"][index]+".png" : ""
                    anchors.centerIn: parent
                }
                Text {
                    text: "NT"
                    visible: index==4
                    anchors.centerIn: parent
                    font.pixelSize: 20
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        bidSuits.expanded = false;
                        box.playerbid(bidNos.currentIndex+1, index, "");
                        bidNos.currentIndex = -1;
                    }
                }
            }
        }

        Behavior on height { NumberAnimation { duration: 250 } }
        Behavior on x { NumberAnimation { duration: 100 } }
    }
}
