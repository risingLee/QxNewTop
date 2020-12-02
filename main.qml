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
    x: 1920/2
    width: 1920/2
    height: 1080
    title: qsTr("")
    property var publicObj: {}
    property var _heigh: 0
    property var _low: 0
    property var dayCount : 365
    property var dayEndCount : 365
    property var endDayCount : 0

    property var currentMonth:new Date().getMonth()
    property var gnameArray: g_lstName
    property var gcodeArray: g_lstData//["SZ300015","SH601788","SH601800"]//
    //    property var gcodeArray:["SZ300357"]
    property var cxcode: "SH601100"
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
                    text: "SH601100"
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
                width: 600
                height: 30
                border.color: "black"
                border.width: 1
                Row
                {
                    anchors.fill: txmonth
                    Text
                    {
                        text: "RSI顶:"
                    }

                    TextEdit
                    {
                        id: rsiH
                        text: "0"
                        width: 30
                        height: 30
                        font.pointSize: 13
                        onTextChanged:
                        {
                            _heigh = text
                        }
                    }
                    Text
                    {
                        text: "RSI底:"
                    }

                    TextEdit
                    {
                        id: rsiL
                        text: "0"
                        width: 30
                        height: 30
                        font.pointSize: 13
                        onTextChanged:
                        {
                            _low = text
                        }
                    }
                    Text
                    {
                        text: "从(天):"
                    }

                    TextEdit
                    {
                        id: tday
                        text: "30"
                        width: 30
                        height: 30
                        font.pointSize: 13
                        onTextChanged:
                        {
                            dayCount = Number(text)
                        }
                    }
                    Text
                    {
                        text: "至(天):"
                    }
                    TextEdit
                    {
                        id: tendday
                        text: "0"
                        width: 50
                        height: 30
                        font.pointSize: 13
                        onTextChanged:
                        {
                            dayEndCount = Number(text)
                        }
                    }
                }
            }
            Button
            {
                id: btnsFenx
                height: 30
                text:"买卖RSI计算"
                property var rsiPoint: 15
                property var rsiCha: 25
                onClicked: {
                    console.log("start rsifx",cxcode)


                    function calBs(mapRsi6,mapRsi67,arrKline,startIndex)
                    {
                        var arrValue = []
                        var money = 100000
                        var moneyshengyu = 0
                        var count = 0
                        var curmoney = money
                        for(var i = startIndex; i < arrKline.length-dayEndCount; ++i )
                        {
                            var yestoday = arrKline[i-1].data
                            var curPease = arrKline[i].data
                            var  ytime = arrKline[i-1].time
                            var time = arrKline[i].time
                            var curValue = mapRsi6[time]
                            var lastValue = mapRsi6[ytime]
                            var cur67Value = mapRsi67[time]

                            var heigh = _heigh
                            var low = _low
                            if(arrValue.length == 0 || arrValue.length%2 == 0)
                            {
                                if(curValue<low)
                                {
                                    var pos = {x:i,y:curPease,y2:curValue,time:time}
                                    count = parseInt(curmoney /curPease)
                                    moneyshengyu += curmoney - (curPease*count)

                                    curmoney = curPease*count
                                    arrValue.push(pos)
                                }
                            }
                            else
                            {
                                if(curValue>heigh)
                                {
                                    var pos = {x:i,y:curPease,y2:curValue,time:time}
                                    curmoney = count * curPease
                                    arrValue.push(pos)
                                }
                            }

                        }
                        tresult.text = "代码:"+cxcode+" 初始:"+ money+ " "+ dayCount+"天后:"+ curmoney+moneyshengyu+" 率:"+((curmoney+moneyshengyu-money)/money ).toFixed(2)*100 + "% 6日RSI高于:"+heigh+"卖出 6日RSI低于:"+low+"买入"
                        //                        console.info("股票代码:"+cxcode+"初始资金:", money," 3年后资金:", curmoney+moneyshengyu,"收益率:",((curmoney+moneyshengyu-money)/money ).toFixed(2)*100 + "%","6RSI高于:",heigh,"买入 6RSI低于:",low,"卖出")
                        return arrValue
                    }
                    function dateMake(time)
                    {
                        var fomat = new Date(time).toLocaleString(Qt.locale("de_DE"), "yyyy-MM-dd HH:mm:ss")
                        return Date.fromLocaleString(Qt.locale(), fomat, "yyyy-MM-dd hh:mm:ss")
                    }

                    function kcha(data1,ydata1,data2,ydata2)
                    {
                        var chaState = ""
                        if(data1 > data2)
                        {
                            if(ydata1 < ydata2)
                            {
                                chaState = "jincha"
                            }
                        }
                        else if(data1 < data2)
                        {
                            if(ydata1 > ydata2)
                            {
                                chaState = "sicha"
                            }
                        }

                        return chaState
                    }

                    function calMaxchaBs(mapRsi6,mapRsi67,arrKline,startIndex)
                    {

                        var maxResult = 0
                        var curSeri = 0
                        for(var seri = 0; seri < 1; seri+=0.01)
                        {
                            var arrValue = []
                            var money = 100000
                            var moneyshengyu = 0
                            var count = 0
                            var curmoney = money
                            for(var i = startIndex; i < arrKline.length-dayEndCount; ++i )
                            {
                                var curPease = arrKline[i].data
                                var curLow = arrKline[i].low
                                var  ytime = arrKline[i-1].time
                                var time = arrKline[i].time
                                var curValue = mapRsi6[time]
                                var lastValue = mapRsi6[ytime]
                                var cur67Value = mapRsi67[time]
                                var last67Vakye = mapRsi67[ytime]

                                var heigh = _heigh
                                var low = _low
                                var chaState = kcha(curValue,lastValue,cur67Value,last67Vakye)

                                if(arrValue.length == 0 || arrValue.length %2 == 0)
                                {
                                    var yma5 = Storage.getMa5(cxcode,time,seri)
                                    //                                console.info("ma5:","yma5:",yma5,"curLow:",curLow)
                                    if(curLow - yma5 < 0 )//f(curValue<10)//
                                    {
                                        count = parseInt(curmoney /curPease)
                                        moneyshengyu += curmoney - (curPease*count)
                                        curmoney = curPease*count
                                        arrValue.push({time:time, value: curValue, pease:curPease})
                                        //                                    console.info(new Date(time).toLocaleString(Qt.locale("de_DE"), "yyyy-MM-dd HH:mm:ss"),"B:",curPease,"余额:",curmoney)
                                    }
                                }
                                else
                                {
                                    if(chaState == "sicha" )//if(curValue>90)//
                                    {
                                        curmoney = count * curPease
                                        arrValue.push({time:time, value: curValue, pease:curPease})
                                        //                                    console.info(new Date(time).toLocaleString(Qt.locale("de_DE"), "yyyy-MM-dd HH:mm:ss"),"S",curPease,"余额:",curmoney)
                                    }
                                }


                            }
                            var result = ((curmoney+moneyshengyu-money)/money ).toFixed(2)*100
                            if(maxResult < result)
                            {
                                maxResult = result
                                curSeri = seri
                            }
                        }
                        console.info(curSeri, maxResult)
                    }

                    function calchaBs(mapRsi6,mapRsi67,arrKline,startIndex,seri)
                    {
                        var arrValue = []
                        var money = 100000
                        var moneyshengyu = 0
                        var count = 0
                        var curmoney = money
                        for(var i = startIndex; i < arrKline.length-dayEndCount; ++i )
                        {
                            var curPease = arrKline[i].data
                            var curLow = arrKline[i].low
                            var  ytime = arrKline[i-1].time
                            var time = arrKline[i].time
                            var curValue = mapRsi6[time]
                            var lastValue = mapRsi6[ytime]
                            var cur67Value = mapRsi67[time]
                            var last67Vakye = mapRsi67[ytime]

                            var heigh = _heigh
                            var low = _low
                            var chaState = kcha(curValue,lastValue,cur67Value,last67Vakye)

                            if(arrValue.length == 0 || arrValue.length %2 == 0)
                            {
                                var yma5 = Storage.getMa5(cxcode,time,seri)
                                console.info("ma5:","yma5:",yma5,"curLow:",curLow)
                                if(curLow - yma5 < 0 )//f(curValue<10)//
                                {
                                    count = parseInt(curmoney /curPease)
                                    moneyshengyu += curmoney - (curPease*count)
                                    curmoney = curPease*count
                                    arrValue.push({time:time, value: curValue, pease:curPease})
                                    console.info(new Date(time).toLocaleString(Qt.locale("de_DE"), "yyyy-MM-dd HH:mm:ss"),"B:",curPease,"余额:",curmoney)
                                }
                            }
                            else
                            {
                                if(chaState == "sicha" )//if(curValue>90)//
                                {
                                    curmoney = count * curPease
                                    arrValue.push({time:time, value: curValue, pease:curPease})
                                    console.info(new Date(time).toLocaleString(Qt.locale("de_DE"), "yyyy-MM-dd HH:mm:ss"),"S",curPease,"余额:",curmoney)
                                }
                            }


                        }
                        tresult.text = "代码:"+cxcode+" 初始:"+ money+ " "+ dayCount+"天后:"+ curmoney+moneyshengyu+" 率:"+((curmoney+moneyshengyu-money)/money ).toFixed(2)*100 + "%"
                        return arrValue
                    }

                    function drawChartLine()
                    {
                        var mapRsi6 = Contrllor.getBs(cxcode,6)
                        var mapRsi24 = Contrllor.getBs(cxcode,24)
                        var mapRsi40 = Contrllor.getBs(cxcode,40)
                        var mapRsi67 = Contrllor.getBs(cxcode,67)

                        var arrKline = Contrllor.getDayArray(cxcode)

                        var startIndex = arrKline.length -dayCount
                        var seri = 0.01
                        var arrBs = calBs(mapRsi6,mapRsi67,arrKline,startIndex)
                        var arrchaBs = calchaBs(mapRsi6,mapRsi67,arrKline,startIndex,seri)//calMaxchaBs(mapRsi6,mapRsi67,arrKline,startIndex) //

                        var maxValue = 0
                        newLine.clear()
                        chart.newScatterBuy.clear()
                        chart.newScatterScale.clear()
                        chartRsi.newScatterBuy.clear()
                        chartRsi.newScatterScale.clear()
                        chartRsi.newLine1.clear()
                        chartRsi.newLine2.clear()
                        chartRsi.newLine4.clear()
                        for(var i = startIndex; i < arrKline.length-dayEndCount; ++i)
                        {
                            if(arrKline[i] > maxValue)
                                maxValue = arrKline[i].data
                            var time = dateMake(arrKline[i].time)
                            newLine.append(time,arrKline[i].data)
                            chartRsi.newLine1.append(time,mapRsi6[arrKline[i].time])
                            chartRsi.newLine2.append(time,mapRsi24[arrKline[i].time])
                            chartRsi.newLine4.append(time,mapRsi67[arrKline[i].time])
                        }

                        x_axis.min = dateMake(arrKline[startIndex].time)
                        x_axis.max = dateMake(arrKline[arrKline.length-dayEndCount-1].time)
                        x_axisrsi.min = dateMake(arrKline[startIndex].time)
                        x_axisrsi.max = dateMake(arrKline[arrKline.length-dayEndCount-1].time)

                        chart.newScatterBuy.axisX = x_axis
                        chart.newScatterScale.axisX = x_axis
                        chartRsi.newLine1.axisX = x_axisrsi
                        chartRsi.newLine2.axisX = x_axisrsi
                        chartRsi.newLine3.axisX = x_axisrsi
                        chartRsi.newLine4.axisX = x_axisrsi


                        for(var i = 0; i < arrBs.length-1; i+=2)
                        {
                            chart.newScatterBuy.append(dateMake(arrBs[i].time),arrBs[i].y)
                            chart.newScatterScale.append(dateMake(arrBs[i+1].time),arrBs[i+1].y)
                            chartRsi.newScatterBuy.append(dateMake(arrBs[i].time),arrBs[i].y2)
                            chartRsi.newScatterScale.append(dateMake(arrBs[i+1].time),arrBs[i+1].y2)
                        }
                        for(var i = 0; i < arrchaBs.length-1; i+=2)
                        {
                            chart.newScatterBuy.append(dateMake(arrchaBs[i].time),arrchaBs[i].pease)
                            chart.newScatterScale.append(dateMake(arrchaBs[i+1].time),arrchaBs[i+1].pease)
                            chartRsi.newScatterBuy.append(dateMake(arrchaBs[i].time),arrchaBs[i].value)
                            chartRsi.newScatterScale.append(dateMake(arrchaBs[i+1].time),arrchaBs[i+1].value)
                        }

                        chartRsi.newLine1.color = "white"
                        chartRsi.newLine2.color = "blue"
                        chartRsi.newLine3.color = "pink"
                        chartRsi.newLine4.color = "purple"
                        newLine.color = "red"
                        chart.newScatterBuy.color = "red"
                        chart.newScatterScale.color = "green"
                        chartRsi.newScatterBuy.color = "red"
                        chartRsi.newScatterScale.color = "green"

                        //                        chartRsi.axisX(chartRsi.newLine1).max = maxDayTime;
                        chartRsi.axisY(chartRsi.newLine1).max = 100
                        //                        chartRsi.axisX(chartRsi.newLine2).max = maxDayTime;
                        chartRsi.axisY(chartRsi.newLine4).max = 100
                        chart.axisY(newLine).max = 100;

                    }
                    drawChartLine()
                    console.log("rsifx finish")
                }
            }
            Button
            {
                id: btnsFenx1
                height: 30
                text:"RSI计算"
                onClicked: {
                    function calBs1(mapRsi6,mapRsi67,arrKline,startIndex)
                    {
                        var maxshouyi = 0
                        for(var heigh = 0; heigh < 100; ++heigh)
                        {
                            for(var low = 0; low < 100; ++ low)
                            {
                                var shouyilv = 0
                                var arrValue = []
                                var money = 100000
                                var moneyshengyu = 0
                                var count = 0
                                var curmoney = money
                                for(var i = startIndex; i < arrKline.length-dayEndCount; ++i )
                                {
                                    var yestoday = arrKline[i-1].data
                                    var curPease = arrKline[i].data
                                    var  ytime = arrKline[i-1].time
                                    var time = arrKline[i].time
                                    var curValue = mapRsi6[time]
                                    var lastValue = mapRsi6[ytime]
                                    var cur67Value = mapRsi67[time]
                                    if(arrValue.length == 0 || arrValue.length%2 == 0)
                                    {
                                        if(curValue<low)
                                        {
                                            var pos = {x:i,y:curPease,y2:curValue}
                                            count = parseInt(curmoney /curPease)
                                            moneyshengyu += curmoney - (curPease*count)
                                            curmoney = curPease*count
                                            arrValue.push(pos)
                                        }
                                    }
                                    else
                                    {
                                        if(curValue>heigh)
                                        {
                                            var pos = {x:i,y:curPease,y2:curValue}
                                            curmoney = count * curPease
                                            arrValue.push(pos)
                                        }
                                    }

                                    shouyilv = (curmoney+moneyshengyu-money)/money
                                    if(maxshouyi < shouyilv)
                                    {
                                        maxshouyi = shouyilv
                                        publicObj = {low: low, heigh: heigh, max:maxshouyi}
                                    }

                                }

                            }
                        }
                        rsiL.text = publicObj.low
                        rsiH.text = publicObj.heigh
                        console.info("final result: ",JSON.stringify(publicObj))
                    }

                    console.log("start sfx",cxcode)
                    var mapRsi6 = Contrllor.getRsiMap(cxcode,6)
                    //                        var arr24 = Contrllor.getBs(cxcode,24)
                    //                        var arr40 = Contrllor.getBs(cxcode,40)
                    var mapRsi67 = Contrllor.getRsiMap(cxcode,67)

                    var arrKline = Contrllor.getDayArray(cxcode)

                    var startIndex = arrKline.length -dayCount
                    var arrBs = calBs1(mapRsi6,mapRsi67,arrKline,startIndex)
                    console.log("sfx finish")
                }
            }
            Text
            {
                id: tresult
                color:"red"
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

        ChartView {
            id:chart;
            backgroundColor: "black"
            property var newScatterBuy : chart.createSeries(ChartView.SeriesTypeScatter,"Buy");
            property var newScatterScale : chart.createSeries(ChartView.SeriesTypeScatter,"Scale");
            property var newLine3:newLine
            width: 1500
            height: 500
            theme: ChartView.ChartThemeBrownSand
            antialiasing: true
            animationOptions:ChartView.GridAxisAnimations
            DateTimeAxis {
                id : x_axis

                format: "hh::mm" //设置显示样式
                //                labelsFont.pointSize: view.lablefont
            }
            LineSeries
            {
                id: newLine
                color:"red"
                axisX: x_axis
            }
        }
        ChartView {
            id:chartRsi;
            backgroundColor: "black"
            titleColor:"white"
            DateTimeAxis {
                id : x_axisrsi

                format: "hh::mm" //设置显示样式
                //                labelsFont.pointSize: view.lablefont
            }
            property var newLine1 : chartRsi.createSeries(ChartView.SeriesTypeLine,"RSI6");
            property var newLine2 : chartRsi.createSeries(ChartView.SeriesTypeLine,"RSI24");
            property var newLine3 : chartRsi.createSeries(ChartView.SeriesTypeLine,"RSI40");
            property var newLine4 : chartRsi.createSeries(ChartView.SeriesTypeLine,"RSI67");
            property var newScatterBuy : chartRsi.createSeries(ChartView.SeriesTypeScatter,"Buy");
            property var newScatterScale : chartRsi.createSeries(ChartView.SeriesTypeScatter,"Scale");
            width: 1500
            height: 300
            theme: ChartView.ChartThemeBrownSand
            antialiasing: true
            animationOptions:ChartView.GridAxisAnimations
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

                property var mbvalue: 0
                property var newLine : chartsview.createSeries(ChartView.SeriesTypeLine,gListModel.get(index)._code + gListModel.get(index)._name);
                //                property var newLine1 : chartsview.createSeries(ChartView.SeriesTypeLine,"next");
                //            property var newLine2 : chartsview.createSeries(ChartView.SeriesTypeLine,"2");
                //            property var newLine3 : chartsview.createSeries(ChartView.SeriesTypeLine,"3");
                Text
                {
                    id: tt
                    anchors.centerIn: parent
                    color: "red"

                }

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

                    if((((Math.pow(dimax, item.length+1).toFixed(2)-max)/max)*100).toFixed(2) < 1)
                    {
                        visible = false
                    }

                    tt.text += "one:"+ Math.pow(dimax, item.length+1).toFixed(2)+"涨幅:"+(((Math.pow(dimax, item.length+1).toFixed(2)-max)/max)*100).toFixed(2) + "%\ntwo:"+Math.pow(dimax, item.length+2).toFixed(2)+"涨幅:"+(((Math.pow(dimax, item.length+2).toFixed(2)-max)/max)*100).toFixed(2) + "%\nthree:"+Math.pow(dimax, item.length+3).toFixed(2)+"涨幅:"+(((Math.pow(dimax, item.length+3).toFixed(2)-max)/max)*100).toFixed(2) + "%"


                    chartsview.axisY(newLine).max = Math.pow(dimax, item.length+3);

                    //                    chartsview.axisY(newLine1).max = Math.pow(dimax, item.length+1) + 10;
                }
            }
        }
    }

}
