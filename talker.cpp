#include <QRegExp>
#include <QStringList>
#include <QMessageBox>
#include <QTimer>
#include "talker.h"
#include "networkutils.h"
#include "xmlengine.h"

#define SERVER_UDP_PORT 5500
#define SERVER_TCP_PORT 7070
#define SERVER_LOOKUP_PORT 6060

Talker::Talker(QObject *parent) :
    QObject(parent)
{
    m_tcpClient = 0;
}

void Talker::discoverServer()
{
    m_servListener = new QUdpSocket(this);
    connect(m_servListener, SIGNAL(readyRead()),
            this, SLOT(saveServerAddress()));
    if (!m_servListener->bind(SERVER_LOOKUP_PORT, QUdpSocket::ShareAddress | QUdpSocket::ReuseAddressHint)) {
        QMessageBox::information(NULL, "Can't find the server", "Cannot find the server, please close and start this application again.");
    } else {
        broadcastForServer();
    }
}

void Talker::broadcastForServer()
{
    if (!m_server.isEmpty()) return;
    NetworkUtils::broadcast("discover", SERVER_UDP_PORT);
    QTimer::singleShot(1000, this, SLOT(broadcastForServer()));
}

void Talker::saveServerAddress()
{
    disconnect(m_servListener, SIGNAL(readyRead()), 0, 0);
    QHostAddress sender;
    NetworkUtils::readBroadcast(m_servListener, &sender, true);
    m_server = sender.toString();
    m_servListener->close();
    connectToServer();
}

void Talker::connectToServer()
{
    m_tcpClient = new QTcpSocket();
    m_tcpClient->connectToHost(m_server, SERVER_TCP_PORT, QIODevice::ReadWrite);
    connect(m_tcpClient, SIGNAL(connected()),
            this, SIGNAL(serverConnected()));
    connect(m_tcpClient, SIGNAL(readyRead()),
            this, SLOT(readServer()));
    connect(m_tcpClient, SIGNAL(disconnected()),
            m_tcpClient, SLOT(deleteLater()));
}

void Talker::identify(int table, int player)
{
    m_table = table;
    m_player = player;
    m_map.clear();
    m_map.insert("message", "identify");
    m_map.insert("table", QString::number(table));
    m_map.insert("player", QString::number(player));
    NetworkUtils::tcpSend(XMLEngine::buildXml(m_map), m_tcpClient);
}

void Talker::readServer()
{
    QString msg = NetworkUtils::tcpRecv(m_tcpClient);
    parseMessage(msg);
}

void Talker::parseMessage(QString msg)
{
    const StringMap stuff = XMLEngine::parseXml(msg);
    QString message = stuff["message"].toLower();

    if (message == "ack") {
        int ok = stuff["ok"].toInt();
        emit authenticated(ok);
        if (ok) {
            emit newGame();
            if (m_player>3 && stuff.contains("data")) {
                emit matchReceived(stuff["data"]);
            }
        }
    }
    else if (message == "board") {
        emit boardReceived(stuff["dealer"].toInt(), stuff["vulnerable"].toInt(),
                           stuff["round"].toInt(), stuff["number"].toInt(),
                           stuff["ns_pair"].toInt(), stuff["ew_pair"].toInt());
        // used for sending dummy cards
        m_cards = stuff["cards"];
        QStringList cardsList = m_cards.split(QChar(','));
        emit cardsReceived(m_player, QVariant::fromValue(cardsList));
    }
    else if (message == "move") {
        emit moveReceived(stuff["player"].toInt(), stuff["type"].toInt(), stuff["data"]);
    }
    else if (message == "dummy_cards") {
        if (m_player>3) return;
        QStringList dummyCards = stuff["cards"].split(QChar(','));
        emit dummyCardsReceived(QVariant::fromValue(dummyCards));
    }
    else if (message == "notification") {
        emit notificationReceived(stuff["note"]);
    }
    else if (message == "resume_data") {
        emit matchReceived(stuff["data"]);
    }
}

int Talker::player()
{
    return m_player;
}

void Talker::setCards(QString cards)
{
    m_cards = cards;
}

void Talker::broadcastMove(int type, QString data)
{
    StringMap m = m_map;
    m["message"] = "move";
    m.insert("type", QString::number(type));
    m.insert("data", data);
    NetworkUtils::tcpSend(XMLEngine::buildXml(m), m_tcpClient);
}

void Talker::broadcastDummyCards()
{
    StringMap m = m_map;
    m["message"] = "dummy_cards";
    m.insert("cards", m_cards);
    NetworkUtils::tcpSend(XMLEngine::buildXml(m), m_tcpClient);
}

void Talker::reportScore(int score)
{
    StringMap m = m_map;
    m["message"] = "score";
    m.insert("score", QString::number(score));
    NetworkUtils::tcpSend(XMLEngine::buildXml(m), m_tcpClient);
}

void Talker::sendReady()
{
    emit playerNumber(m_player);
    if (m_player>3)
        return;
    StringMap m = m_map;
    m["message"] = "ready";
    NetworkUtils::tcpSend(XMLEngine::buildXml(m), m_tcpClient);
}

