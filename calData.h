#ifndef CALDATA_H
#define CALDATA_H

#include <QThread>
#include <QNetworkAccessManager>
#include <QNetworkCookie>
#include <QNetworkCookieJar>
#include "qreplytimeout.h"
class CalData : public QThread
{
    Q_OBJECT
public:
    CalData();
    Q_INVOKABLE void saveKLine(QString code, QString type, QString value);
    Q_INVOKABLE QString getKLine(QString code, QString type);
protected:
    void run();
signals:
    void responseFaild();
    void responseSuccessful(QString text);
public slots:
    void slot_changeUrl(QString url);
private:
    QString m_url;
    QNetworkAccessManager * rmanager;
    QNetworkAccessManager *manager;
    QList<QNetworkCookie> allcookies;
    QNetworkRequest request;

};

#endif // CALDATA_H

