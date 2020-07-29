import QtQuick 2.6
import QtQuick.Controls 1.4

import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import "xmlhttprequest.js" as XmlHttpRequest
import "Storage.js" as Storage
import "Contrllor.js" as Contrllor
import REQUEST 1.0
Window {
    visible: true
    width: 1920
    height: 1080
    title: qsTr("Hello World")
    property var currentMonth:new Date().getMonth()
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
    property var _DATAURL: "https://stock.xueqiu.com/v5/stock/chart/kline.json?symbol="
    property var _DAYURL: "&begin=1593759367604&period=day&type=before&count=-9999&indicator=kline,pe,pb,ps,pcf,market_capital,agt,ggt,balance"
    property var _MONURL: "&begin=1582878803954&period=month&type=before&count=-9999&indicator=kline,pe,pb,ps,pcf,market_capital,agt,ggt,balance;"
    signal changeUrl(var url)
    property var _index: 0
    Component.onCompleted: {
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

    Request{
        id: r_netrequest

        onResponseSuccessful:{
            console.log("成功 ", gcodeArray[_index]," id:", _index)
            console.log(text.length)
            if(text.length > 0)
            {
                var obj = JSON.parse(text);
                if(cmonth.checked)
                    Contrllor.datafactory(obj.data.item, gcodeArray[_index])
                var type = ""
                if(cday.checked)
                {


                    type = "day"

                    saveKLine(gcodeArray[_index],type,text)
                }
                ++_index;
                pb.value = _index;
                if(_index >= gcodeArray.length)
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
                        changeUrl(_DATAURL+gcodeArray[_index]+_MONURL)
                    }
                    if(cday.checked)
                    {
                        Storage.initializeD();
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
                    text: "SH600001"
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
                    changeUrl("https://stock.xueqiu.com/v5/stock/chart/kline.json?symbol="+textGet.text+"&begin=1582878803954&period=month&type=before&count=-9999&indicator=kline,pe,pb,ps,pcf,market_capital,agt,ggt,balance;")
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
                    Contrllor.getAllData()
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
            delegate: Image
            {
                source: "http://image.sinajs.cn/newchart/monthly/n/"+ _code +".gif"
            }
        }
    }

}
