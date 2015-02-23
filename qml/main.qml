import QtQuick 1.1
import "logic.js" as Logic

Image {
    id: canvas
    source: "images/backgrounds/"+statusBar.bgColor+".jpg"
    smooth: true

    property bool animated: true

    property int dealer: -1
    property int vulnerable: -1
    property int declarer: -1
    property int doubled: 1
    property int turn: -1
    property int dummy: -1
    property int phase: 0
    property int nsPair: -1
    property int ewPair: -1

    property alias coverNo: settings.coverNo
    property alias deckNo: settings.deckNo
    property alias pickCard: pickCardCheck.checked

    property bool spectator

    signal newGame()
    signal closed()

    function setAnimated(value) {
        animated = value;
    }
    function setBoard(dealer, vulnerable, round, boardNo, ns_pair, ew_pair) {
        canvas.dealer = dealer;
        canvas.vulnerable = vulnerable;
        statusBar.round = round;
        statusBar.boardNo = boardNo;
        canvas.nsPair = ns_pair;
        canvas.ewPair = ew_pair;
        scoreMessage.text = "";
    }
    function showCards(player, cards) { Logic.showCards(player, cards); }
    function showMove(player, type, data) { Logic.showMove(player, type, data); }
    function showDummyCards(cards) { Logic.showDummyCards(cards); }

    Component.onCompleted: {
        if (false) {
            me.num = 2;
            spectator = false;
            Logic.updateDB();
            setBoard(1, 0, 1, 12);
            showCards(2, ["0","1","2","3","4","5","6","7","8","9","10","11","12"]);
            showMove(1, 0, "1,0");
            showMove(2, 0, "pass");
            showMove(3, 0, "pass");
            showMove(0, 0, "pass");
        }
    }

    Connections {
        target: talker
        onPlayerNumber: {
            spectator = num>3;
            if (!spectator)
                me.num = num;
            else
                me.num = 2; // set spectator view to show south player at bottom
            Logic.updateDB();
            scoreMessage.text = "Waiting for other players...";
        }
        onBoardReceived: setBoard(dealer, vulnerable, round, boardNo, ns_pair, ew_pair);
        onCardsReceived: showCards(player, cards);
        onDummyCardsReceived: showDummyCards(cards);
        onNotificationReceived: {
            if (note.indexOf("Tournament over")!=-1) {
                phase=4;
            }
            scoreMessage.text += "\n\n"+note;
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: settings.height=0;
    }

    Timer {
        id: sendDummyCardsTimer
        interval: 300
        onTriggered: {
            talker.broadcastDummyCards();
            Logic.dummyCardsOpen = true;
        }
    }

    Timer {
        id: turnTimer
        property int nextTurn: -1
        interval: moveCardsBackTimer.interval
        onTriggered: canvas.turn = nextTurn;
    }

    StatusBar {
        id: statusBar
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        showText: phase>0 && phase <3 && !spectator
        showNewGameBtn: phase==3
        showCloseBtn: spectator || phase==4
        onSettingsTriggered: {
            settings.height = settings.height>0 ? 0 : 150;
        }
        onNewGame: canvas.newGame();
        onClosed: canvas.closed();
    }
    // these are required because some script might set another
    // message to show (eg, invalid move), after that the turn
    // messages won't be automatically updated without the
    // following 2 lines
    onTurnChanged: statusBar.text = turnMessage(turn, phase);
    onPhaseChanged: statusBar.text = turnMessage(turn, phase);

    function turnMessage(turn, phase) {
        if (turn==me.num && dummy!=me.num) return phase==1 ? "Your turn to bid" : "Your turn to play a card";
        if (turn==dummy && dummy==(me.num+2)%4 && phase==2) return "Your turn to play dummy's card";
        return "";
    }

    Item {
        id: container
        height: parent.height
        width: height*4/3
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Image {
        id: centerShadow
        source: "images/Center_Shadow.png"
        anchors {
            centerIn: parent
            bottomMargin: statusBar.height
        }
        visible: phase>1
    }

    Display {
        id: display
        visible: phase>0
        anchors {
            top: parent.top; topMargin: 5
            left: parent.left; leftMargin: parent.width*5/parent.height
        }

        dealer: canvas.dealer
        vulnerable: canvas.vulnerable
        declarer: phase>1 ? canvas.declarer : -1
        contract: phase>1 ? Logic.lastValidBid.split(":")[1] : ""
        doubled: phase>1 ? canvas.doubled : 0
    }

    BiddingBoard {
        id: biddingBoard
        anchors {
            top: topPlayer.bottom
            topMargin: 15
            horizontalCenter: me.horizontalCenter
        }
        height: 200
        width: 400
        visible: false
        opacity: visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 250 } }
    }

    BiddingBox {
        id: biddingBox
        anchors {
            bottom: me.top
            bottomMargin: 30
            horizontalCenter: me.horizontalCenter
        }
        width: choice==1 ? 370 : 450
        height: 170
        opacity: phase==1 && turn==me.num && !spectator
        Behavior on opacity { NumberAnimation { duration: 250 } }

        onPlayerbid: {
            if (Logic.validateBid(bidNo, suit, special)) {
                var bid = special=="" ? bidNo+","+suit : special;
                talker.broadcastMove(0, bid);
                showMove(me.num, 0, bid);
            }
        }
    }

    Timer {
        id: moveCardsBackTimer
        interval: 1000*animated
        onTriggered: Logic.moveCardsToPlayers();
    }

    ScoreBoard {
        id: scoreBoard
        anchors {
            top: leftPlayer.bottom
            topMargin: 20
            left: parent.left
            leftMargin: 30
            bottom: statusBar.top
            bottomMargin: 10
            right: me.left
            rightMargin: 20
        }
        visible: phase>1
        opacity: visible ? 1 : 0
    }

    Timer {
        id: stopBidTimer
        interval: 1000*animated
        onTriggered: {
            biddingBoard.visible = biddingBox.visible = false;
        }
    }

    Rectangle {
        color: "black"
        property int margin: -5
        anchors {
            fill: scoreMessage
            topMargin: margin
            bottomMargin: margin
            leftMargin: margin*2
            rightMargin: margin*2
        }
        opacity: visible ? 0.7 : 0
        radius: 7
        visible: scoreMessage.visible
        Behavior on opacity { NumberAnimation { duration: 250 } }
    }
    Text {
        id: scoreMessage
        anchors {
            horizontalCenter: me.horizontalCenter
            bottom: me.top
            bottomMargin: 40
        }
        font.pixelSize: 20
        color: "white"
        visible: text!=""
        opacity: visible
        Behavior on opacity { NumberAnimation { duration: 250 } }
    }

    Timer {
        id: scoreTimer
        interval: (moveCardsBackTimer.interval+100)*animated
        onTriggered: Logic.displayScore();
    }

    PlayerLabel { player: topPlayer }
    Player {
        id: topPlayer
        num: (me.num+2)%4
        orientation: Qt.Horizontal
        pickDirection: 1
        anchors {
            top: parent.top
            topMargin: 30
            horizontalCenter: parent.horizontalCenter
        }
        mouseEnabled: phase==2 && topPlayer.num==dummy && turn==topPlayer.num && settings.height==0 && !spectator

        onCardClicked: {
            if (Logic.validateMove(num, parseInt(cardNoString))) {
                talker.broadcastMove(2, indexString);
                showMove(me.num, 2, indexString);
            } else {
                statusBar.text = "You cannot play that card!";
            }
        }

        function isValid(cardNo) { return Logic.validateMove(num, cardNo); }
    }

    PlayerLabel { player: leftPlayer }
    Player {
        id: leftPlayer
        num: (me.num+1)%4
        orientation: Qt.Vertical
        anchors {
            left: container.left
            leftMargin: 40
            verticalCenter: parent.verticalCenter
        }
    }

    PlayerLabel { player: rightPlayer }
    Player {
        id: rightPlayer
        num: (me.num+3)%4
        orientation: Qt.Vertical
        anchors {
            right: container.right
            rightMargin: 30
            verticalCenter: parent.verticalCenter
        }
    }

    PlayerLabel { player: me }
    Player {
        id: me
        orientation: Qt.Horizontal
        pickDirection: -1
        anchors {
            bottom: statusBar.top
            bottomMargin: 10
            horizontalCenter: parent.horizontalCenter
        }
        mouseEnabled: phase==2 && me.num!=dummy && turn==me.num && settings.height==0 && !spectator

        onCardClicked: {
            if (Logic.validateMove(me.num, parseInt(cardNoString))) {
                talker.broadcastMove(1, cardNoString);
                showMove(me.num, 1, indexString);
            } else {
                statusBar.text = "You cannot play that card!";
            }
        }

        function isValid(cardNo) { return Logic.validateMove(me.num, cardNo); }
    }

    CheckBox {
        id: pickCardCheck
        text: "Pick card before playing"
        checked: true
        visible: phase>1 && !spectator
        anchors {
            left: me.right
            leftMargin: 20
            bottom: me.bottom
            bottomMargin: 5
        }
    }

    SettingsBox {
        id: settings
        width: parent.width
        height: 0
        anchors {
            bottom: statusBar.top
        }
    }
}
