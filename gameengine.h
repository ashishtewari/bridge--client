#ifndef GAMEENGINE_H
#define GAMEENGINE_H

#include <QObject>
#include <QDeclarativeView>
#include <QTimer>
#include <QVariant>
#include "xmlengine.h"

class InfoDialog;
class Talker;

class GameEngine : public QObject
{
    Q_OBJECT
public:
    explicit GameEngine(QObject *parent = 0);
    
signals:
    void ready();
    
public slots:
    void reset();
    void playMatch(QString match);
    void playListedMoves();
    void playMove(int player, int type, QString data);

private:
    InfoDialog *m_dlg;
    Talker *m_talker;
    QDeclarativeView *qmlView;
    QObject *qmlItem;
    QList<StringMap> m_moveItems;

    QTimer m_playTimer;
    
};

#endif // GAMEENGINE_H
