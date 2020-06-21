#include "request.h"
#include <QDebug>
#include <QEventLoop>
#include <QTextCodec>
Request::Request()
{
    rmanager = new QNetworkAccessManager();
    QNetworkRequest req;
    req.setUrl(QUrl("https://xueqiu.com/"));
    QNetworkAccessManager nManager;
    QNetworkReply* getreply=nManager.get(req);
    QEventLoop loop;
    //下载完成后，直接退出子进程
    connect(getreply, SIGNAL(finished()), &loop, SLOT(quit()));
    //子进程开始运行
    loop.exec();
    allcookies=nManager.cookieJar()->cookiesForUrl(QUrl("https://xueqiu.com/"));
}

void Request::slot_changeUrl(QString url)
{
    m_url = url;
    start();
}

void Request::run()
{
    QNetworkAccessManager *manager = new QNetworkAccessManager();
    QVariant var;
    var.setValue(allcookies);
    QNetworkRequest request;
    request.setHeader(QNetworkRequest::CookieHeader,var);
    request.setUrl(QUrl(m_url) );
    QNetworkReply * qreply= manager->get(request );

    QReplyTimeout *pTimeout = new QReplyTimeout(qreply, 10000);

    //下载超时
    connect(pTimeout, &QReplyTimeout::timeout, [=]() {
        qDebug() << "Timeout";
        emit responseFaild();
        manager->deleteLater();
        pTimeout->deleteLater();
        this->quit();

    });

    //多线程下载数据 成功
    connect(manager,&QNetworkAccessManager::finished,[=](){

        QString str = qreply->readAll();
        emit responseSuccessful(str);
        qreply->abort();
        qreply->deleteLater();
        manager->deleteLater();
        this->quit();

    }
    );
    this->exec();
}

void Request::rrun()
{

    request.setUrl(QUrl(m_url) );
    QNetworkReply * qreply= rmanager->get(request );
    QReplyTimeout *pTimeout = new QReplyTimeout(qreply, 10000);
    //下载超时
    connect(pTimeout, &QReplyTimeout::timeout, [=]() {
        qDebug() << "Timeout";
        emit responseFaild();
    });

    //多线程下载数据 成功
    connect(rmanager,&QNetworkAccessManager::finished,[=](){
        QString str = qreply->readAll();
        emit responseSuccessful(str);
//        qreply->abort();
//        qreply->deleteLater();
    }
    );
}
