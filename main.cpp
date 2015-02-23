#include <QApplication>
#include "gameengine.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    GameEngine engine;

    return app.exec();
}
