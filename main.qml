import QtQuick 2.6
import QtQuick.Controls 1.4

import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import "xmlhttprequest.js" as XmlHttpRequest
import "Storage.js" as Storage
import "Contrllor.js" as Contrllor
import REQUEST 1.0
import QtCharts 2.2
Window {
    visible: true
    width: 1920
    height: 1080
    title: qsTr("Hello World")
    property var currentMonth:new Date().getMonth()
    property var gnameArray: g_lstName
    property var gcodeArray: g_lstData//["SZ300015","SH601788","SH601800"]//
    //    property var gcodeArray:["SZ300357"]
    property var cxcode: "SZ300015"
    property var yearCount: 5
    property var monthCount: yearCount*12
    property var smonthCount: 71
    property var seri: 0.5
    property var serigao: 0.5
    property var gCodeMap: null
    property var gCodeMapD: null
    property var curDate : new Date()
    property var _DATAURL: "https://stock.xueqiu.com/v5/stock/chart/kline.json?symbol="
    property var _DAYURL: "&begin="+Date.parse(curDate)+"&period=day&type=before&count=-9999&indicator=kline,pe,pb,ps,pcf,market_capital,agt,ggt,balance"
    property var _MONURL: "&begin="+Date.parse(curDate)+"&period=month&type=before&count=-9999&indicator=kline,pe,pb,ps,pcf,market_capital,agt,ggt,balance;"
    signal changeUrl(var url)
    property var _index: 0
    Component.onCompleted: {

        if(curDate.getHours() < 15 && (curDate.getHours() >= 9 && curDate.getMinutes() > 30))
        {
            curDate.setHours(0)
            curDate.setMinutes(0)
            curDate.setSeconds(0)
        }
        console.info(Date.parse(curDate))
        //        console.info(value,new Date(value).toLocaleString(Qt.locale("de_DE") , "yyyy-MM-dd HH:mm:ss") )
        gCodeMap = {}
        gCodeMapD = {}
        //Contrllor.getLocationData()
        changeUrl.connect(r_netrequest.slot_changeUrl)
    }

    Timer
    {
        id: timer
        interval: 5000; running: false; repeat: true
        onTriggered: {
            if(currentMonth !== new Date().getMonth() )
            {
                console.info("in")
                Storage.deleteDataBase()
                _index = 0
                pb.minimumValue  = 0
                pb.maximumValue = gcodeArray.length-1
                Storage.initialize();
                changeUrl(_DATAURL + gcodeArray[_index] + _MONURL)

            }
            else
            {
                console.info("not yeap")
            }

        }
    }
    property var signalSearch: false
    Request{
        id: r_netrequest

        onResponseSuccessful:{
            var codeName = gcodeArray[_index]
            if(signalSearch)
                codeName = textGet.text
            console.log("成功 ", codeName," id:", _index)
            console.log(text.length)

            if(text.length > 0)
            {
                var obj = JSON.parse(text);
                if(cmonth.checked)
                    Contrllor.datafactory(obj.data.item, codeName)
                var type = ""
                if(cday.checked)
                {
                    type = "day"
                }
                if(cmonth.checked)
                {
                    type = "month"
                }

                saveKLine(codeName,type,text)
                ++_index;
                pb.value = _index;
                if(_index >= gcodeArray.length)
                    return
                if(signalSearch)
                    return
                if(gcodeArray[_index])
                {
                    if(cmonth.checked)

                        changeUrl(_DATAURL+gcodeArray[_index]+_MONURL)
                    if(cday.checked)
                        changeUrl(_DATAURL+gcodeArray[_index]+_DAYURL)
                }
            }

        }


        onResponseFaild:{
            console.log("超时失败等")
        }

    }



    Column
    {
        x: 0
        y: 0
        width: 1920
        height: 1080

        ProgressBar
        {
            id: pb
            width: 600
            height: 30

        }
        GroupBox {
            title: qsTr("Synchronize")
            RowLayout {
                anchors.fill: parent
                CheckBox { id: cday;checked: true;text: qsTr("day") }
                CheckBox { id: cweel;text: qsTr("week") }
                CheckBox { id: cmonth;text: qsTr("month") }
            }
        }
        TextInput
        {
            id: cookieTx
            width: 600
            height: 50
        }


        Row
        {
            Button
            {
                width:80
                height:30
                text: "获取全部数据"
                onClicked:
                {
                    pb.minimumValue  = 0
                    pb.maximumValue = gcodeArray.length-1
                    if(cmonth.checked){
                        Storage.initialize();
                        signalSearch = false
                        changeUrl(_DATAURL+gcodeArray[_index]+_MONURL)
                    }
                    if(cday.checked)
                    {
                        Storage.initializeD();
                        signalSearch = false
                        changeUrl(_DATAURL+gcodeArray[_index]+_DAYURL)
                    }
                }
            }

            Button
            {
                id: btnDel
                width: 80
                height: 30
                text:"清除数据"
                onClicked: {
                    Storage.deleteDataBase()
                }
            }
            Rectangle {
                id: txcode1
                y: 0
                width: 100
                height: 30
                border.width: 1
                TextEdit {
                    id: textGet
                    text: "SH601200"
                    anchors.fill: parent
                    font.pointSize: 13
                    anchors.margins: 3
                }
                border.color: "#000000"
            }

            Button
            {
                id: btnSet
                height: 30
                text:"获取"
                onClicked:{
                    signalSearch = true
                    console.info(_DATAURL+textGet.text+_DAYURL)
                    changeUrl(_DATAURL+textGet.text+_DAYURL)
                    //changeUrl("https://stock.xueqiu.com/v5/stock/chart/kline.json?symbol="+textGet.text+"&begin=1582878803954&period=month&type=before&count=-9999&indicator=kline,pe,pb,ps,pcf,market_capital,agt,ggt,balance;")
                }
            }

        }



        Row
        {
            Rectangle
            {
                id: txcode
                width: 100
                height: 30
                border.color: "black"
                border.width: 1
                TextEdit
                {
                    text: "sz300357"
                    anchors.fill: parent
                    anchors.margins: 3
                    font.pointSize: 13
                    onTextChanged:
                    {
                        cxcode = text
                    }
                }
            }
            Rectangle
            {
                id: txmonth
                width: 100
                height: 30
                border.color: "black"
                border.width: 1
                TextEdit
                {
                    text: "0"
                    anchors.fill: parent
                    anchors.margins: 3
                    font.pointSize: 13
                    onTextChanged:
                    {
                        smonthCount = Number(text)
                    }
                }
            }
            Button
            {
                id: btnsFenx
                height: 30
                text:"买卖D计算"
                onClicked: {
                    console.log("start sfx",cxcode)
                    Contrllor.getSdata()
                    console.log("sfx finish")
                }
            }
        }

        Row{

            Rectangle
            {
                id: txSeri
                width: 100
                height: 30
                border.color: "black"
                border.width: 1
                TextEdit
                {
                    text:"0.5"
                    anchors.fill: parent
                    anchors.margins: 3
                    font.pointSize: 13
                    onTextChanged:
                    {
                        seri = Number(text)
                    }
                }
            }
            Rectangle
            {
                id: txYear
                width: 100
                height: 30
                border.color: "black"
                border.width: 1
                TextEdit
                {
                    text:"5"
                    anchors.fill: parent
                    anchors.margins: 3
                    font.pointSize: 13
                    onTextChanged:
                    {
                        yearCount = Number(text)
                    }
                }
            }
            Button
            {
                id: btnFenx
                height: 30
                text:"概率选G"
                onClicked: {
                    console.log("start fx",seri,monthCount)
                    Storage.findYaLiMax()
                    console.log("fx finish")
                }
            }
        }

        Row {
            RadioButton {
                id: radioButton
                height: 30
                text: qsTr("反指标")
            }

            Rectangle {
                id: txSeri1
                width: 100
                height: 30
                border.color: "#000000"
                TextEdit {
                    text: "0.8"
                    anchors.margins: 3
                    font.pointSize: 13
                    anchors.fill: parent
                    onTextChanged:
                    {
                        serigao = Number(text)
                    }
                }
                border.width: 1

            }

            Button {
                id: btnFenx1
                height: 30
                text: "高点选G"
                onClicked: {
                    console.log("start fx",serigao)
                    var status = 1
                    if(radioButton.checked)
                    {
                        status = 0
                    }

                    Storage.calNewTop(status)
                    console.log("fx finish")
                }
            }
            Button {
                id: btnSCanKLine
                height: 30
                text: "日X扫描"
                onClicked: {
                    console.log("start kline Scan")


                    Storage.scanKLines()
                    console.log("kline Scan finish")
                }
            }
            Button {
                height: 30
                text: "振幅相似度"
                onClicked: {
                    console.log("start Xsd Scan")


                    Storage.scanGz()
                    console.log("kline Xsd finish")
                }
            }
            Button {
                height: 30
                text: "压力监测"
                onClicked: {
                    console.log("start YL Scan")


                    Storage.findYaLi()
                    console.log("kline YL finish")
                }
            }

        }
        ListModel
        {
            id:gListModel
        }

        ListView
        {
            width: parent.width
            height: 300
            orientation: Qt.Horizontal
            model: gListModel
            delegate:  ChartView {
                id: chartsview;
                width: 400
                height: 300

                visible: true
                theme: ChartView.ChartThemeBrownSand
                antialiasing: true


                property var newLine : chartsview.createSeries(ChartView.SeriesTypeLine,gListModel.get(index)._code + gListModel.get(index)._name);
                property var newLine1 : chartsview.createSeries(ChartView.SeriesTypeLine,"next");
                //            property var newLine2 : chartsview.createSeries(ChartView.SeriesTypeLine,"2");
                //            property var newLine3 : chartsview.createSeries(ChartView.SeriesTypeLine,"3");
                Component.onCompleted: {
                    var value = Storage.getKLine(gListModel.get(index)._code, "month" )
                    Storage.newTopSeir(value, gListModel.get(index)._code)

                    var item = gListModel.get(index)._data.item
                    chartsview.axisX(newLine).max = item.length+20;
                    var max = 0
                    var curMonth = 0
                    for (var i = 0; i  < item.length; i++) {

                        var heigh = item[i][2] > item[i][5] ? item[i][2] : item[i][5]
                        newLine.append(i, heigh);
                        if(heigh>max)
                        {
                            max = heigh
                            curMonth = i
                        }
                    }

                    var dimax = Math.pow(max,(1/curMonth) )
                    newLine1.append(item.length+1,Math.pow(dimax, item.length+2))
                    newLine1.color = Qt.tint(newLine1.color, "red");

                    chartsview.axisY(newLine).max = max;
                    chartsview.axisY(newLine1).max = Math.pow(dimax, item.length+2);
                }
            }
        }
    }

}
