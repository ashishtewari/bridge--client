#include "infodialog.h"
#include "ui_infodialog.h"
#include "talker.h"
#include <QMessageBox>

InfoDialog::InfoDialog(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::InfoDialog)
{
    ui->setupUi(this);
    m_connected = false;
    ui->statusLabel->setText("Looking for server...");
}

InfoDialog::~InfoDialog()
{
    delete ui;
}

void InfoDialog::updateLabelServerConnected()
{
    m_connected = true;
    ui->statusLabel->setText("Connected to server");
    if (!ui->buttonBox->isEnabled()) {
        on_buttonBox_accepted();
    }
}

void InfoDialog::on_buttonBox_accepted()
{
    int player;
    if (ui->northRadio->isChecked()) player=0;
    else if (ui->eastRadio->isChecked()) player=1;
    else if (ui->southRadio->isChecked()) player=2;
    else if (ui->westRadio->isChecked()) player=3;
    else if (ui->specRadio->isChecked()) player=4;
    else {
        QMessageBox::critical(this, "No player selected", "Please select your player side (North/East/South/West/Spec).");
        return;
    }
    ui->buttonBox->setEnabled(false);

    if (m_connected) {
        ui->statusLabel->setText("Authenticating...");
        emit authenticateRequest(ui->tableSpin->value(), player);
    }
}

void InfoDialog::updateLabelAuthenticated(bool ok)
{
    if (!ok) {
        QMessageBox::critical(this, "Authentication failure", "The server did not authenticate you, please make sure you have entered the correct details and try again.");
        ui->statusLabel->setText("Connected to server");
        ui->buttonBox->setEnabled(true);
        return;
    }
    ui->statusLabel->setText("Authenticated");
    hide();
}
