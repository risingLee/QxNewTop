#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QFile>
#include <QTextCodec>
int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QStringList lstData;
    QFile file(QCoreApplication::applicationDirPath()+"/sh.txt");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return 0;
    QTextCodec *codec = QTextCodec::codecForName("GBK");
    QString strAll = codec->toUnicode(file.readAll());
    QStringList lstTemp = strAll.trimmed().split(")");

    for(int i = 0; i < lstTemp.length(); ++i)
    {
        QStringList lstInfo = lstTemp[i].split("(");
        if (lstInfo.length() == 2)
        {
            if(QString(lstInfo[0]).indexOf("ST") == -1)
            lstData.append( QString("sh") + QString(lstInfo[1]) );
            qDebug()<<"<<SH>>"<<QString("sh") + QString(lstInfo[1]);
        }
    }
    file.close();
    QFile file2(QCoreApplication::applicationDirPath()+"/sz.txt");
    if (!file2.open(QIODevice::ReadOnly | QIODevice::Text))
        return 0;

    QString strAll2 = codec->toUnicode(file2.readAll().trimmed());
    QStringList lstTemp2 = strAll2.trimmed().split(")");
    for(int i = 0; i < lstTemp2.length()-1; ++i)
    {
        QStringList lstInfo = lstTemp2[i].split("(");
        if (lstInfo.length() == 2)
        {
            if(QString(lstInfo[0]).indexOf("ST") == -1)
            lstData << QString("sz") + lstInfo[1];
            qDebug()<<"<<SZ>>"<<QString("sz") + QString(lstInfo[1]);
        }
    }
    file2.close();

    engine.rootContext()->setContextProperty("g_lstData", lstData);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
