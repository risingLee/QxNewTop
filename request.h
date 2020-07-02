#ifndef REQUEST_H
#define REQUEST_H

#include <QThread>
#include <QNetworkAccessManager>
#include <QNetworkCookie>
#include <QNetworkCookieJar>
#include "qreplytimeout.h"
class Request : public QThread
{
    Q_OBJECT
public:
    Request();
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

#endif // REQUEST_H
//SZ000533 SH603866 SZ002880
