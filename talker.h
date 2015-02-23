#ifndef TALKER_H
#define TALKER_H

#include <QTcpServer>
#include <QTcpSocket>
#include <QUdpSocket>

class Talker : public QObject
{
    Q_OBJECT
public:
    explicit Talker(QObject *parent = 0);
    void discoverServer();
    Q_INVOKABLE void broadcastMove(int type, QString data);
    Q_INVOKABLE void broadcastDummyCards();
    Q_INVOKABLE void reportScore(int score);
    int player();
    void setCards(QString cards);

signals:
    void serverConnected();
    void authenticated(bool);
    void newGame();
    void playerNumber(int num);
    void boardReceived(int dealer, int vulnerable, int round, int boardNo, int ns_pair, int ew_pair);
    void cardsReceived(int player, QVariant cards);
    void moveReceived(int player, int type, QString data);
    void dummyCardsReceived(QVariant cards);
    void notificationReceived(QString note);
    void matchReceived(QString log);

public slots:
    void broadcastForServer();
    void saveServerAddress();
    void identify(int table, int player);
    void readServer();
    void sendReady();

private:
    int m_table;
    int m_player;
    QMap<QString,QString> m_map;
    QString m_cards;

    void connectToServer();
    void parseMessage(QString msg);

    QString m_server; // server's IP address
    QUdpSocket *m_servListener; // for discovering the server
    QTcpSocket *m_tcpClient; // for all in-game communication with server
};

#endif // TALKER_H
