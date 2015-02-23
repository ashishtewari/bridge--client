#ifndef INFODIALOG_H
#define INFODIALOG_H

#include <QDialog>
#include <QCloseEvent>

namespace Ui {
class InfoDialog;
}

class InfoDialog : public QDialog
{
    Q_OBJECT
    
public:
    explicit InfoDialog(QWidget *parent = 0);
    ~InfoDialog();

signals:
    void authenticateRequest(int,int);

private slots:
    void updateLabelServerConnected();
    void on_buttonBox_accepted();
    void updateLabelAuthenticated(bool);

private:
    Ui::InfoDialog *ui;
    bool m_connected;
};

#endif // INFODIALOG_H
