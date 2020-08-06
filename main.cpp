#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QFile>
#include "calData.h"
#include "request.h"
#include <QTextCodec>
int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication   app(argc,argv);

    QQmlApplicationEngine engine;
    QStringList lstName;
    QStringList lstData;
    QFile file(QCoreApplication::applicationDirPath()+"/sh.txt");
    QTextCodec *codec = QTextCodec::codecForName("GBK");
    if (file.open(QIODevice::ReadOnly | QIODevice::Text))
    {

        QString strAll = codec->toUnicode(file.readAll());
        QStringList lstTemp = strAll.trimmed().split(")");

        for(int i = 0; i < lstTemp.length(); ++i)
        {
            QStringList lstInfo = lstTemp[i].split("(");
            if (lstInfo.length() == 2)
            {
                if(QString(lstInfo[0]).indexOf("ST") == -1)
                {
                    lstName.append(lstInfo[0]);
                    lstData.append( QString("SH") + QString(lstInfo[1]) );
                    //            qDebug()<<"<<SH>>"<<QString("sh") + QString(lstInfo[1]);
                }
            }
        }
        file.close();
    }
    QFile file2(QCoreApplication::applicationDirPath()+"/sz.txt");
    if (file2.open(QIODevice::ReadOnly | QIODevice::Text))
    {

        QString strAll2 = codec->toUnicode(file2.readAll().trimmed());
        QStringList lstTemp2 = strAll2.trimmed().split(")");
        for(int i = 0; i < lstTemp2.length()-1; ++i)
        {
            QStringList lstInfo = lstTemp2[i].split("(");
            if (lstInfo.length() == 2)
            {
                if(QString(lstInfo[0]).indexOf("ST") == -1)
                {
                    lstName.append(lstInfo[0]);
                    lstData << QString("SZ") + lstInfo[1];
                }
                //            qDebug()<<"<<SZ>>"<<QString("sz") + QString(lstInfo[1]);300757
            }
        }
        file2.close();
    }
    QFile file3(QCoreApplication::applicationDirPath()+"/cy.txt");
    if (file3.open(QIODevice::ReadOnly | QIODevice::Text))
    {

        QString strAll3 = codec->toUnicode(file3.readAll().trimmed());
        QStringList lstTemp3 = strAll3.trimmed().split(")");
        for(int i = 0; i < lstTemp3.length()-1; ++i)
        {
            QStringList lstInfo = lstTemp3[i].split("(");
            if (lstInfo.length() == 2)
            {
                if(QString(lstInfo[0]).indexOf("ST") == -1)
                {
                    lstName.append(lstInfo[0]);
                    lstData << QString("SZ") + lstInfo[1];
                }
                //                            qDebug()<<"<<CZ>>"<<QString("cz") + QString(lstInfo[1]);
            }
        }
        file3.close();
    }
    qmlRegisterType<Request>("REQUEST", 1, 0, "Request");
    qmlRegisterType<Request>("CALDATA", 1, 0, "CalData");
    engine.rootContext()->setContextProperty("g_lstName", lstName);
    engine.rootContext()->setContextProperty("g_lstData", lstData);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
