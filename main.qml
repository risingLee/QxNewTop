import QtQuick 2.6
import QtQuick.Controls 1.4
//import QtWebEngine 1.5
//import QtWebChannel 1.0
import QtQuick.Window 2.2
import "xmlhttprequest.js" as XmlHttpRequest
import "Storage.js" as Storage
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
    signal changeUrl(var url)
    property var _index: 0
    Component.onCompleted: {
        gCodeMap = {}
        getLocationData()
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
                changeUrl("https://stock.xueqiu.com/v5/stock/chart/kline.json?symbol="+gcodeArray[_index]+"&begin=1582878803954&period=month&type=before&count=-9999&indicator=kline,pe,pb,ps,pcf,market_capital,agt,ggt,balance;")

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
                datafactory(obj.data.item, gcodeArray[_index])
                ++_index;
                pb.value = _index;
                if(_index >= gcodeArray.length)
                    return
                //console.log("https://stock.xueqiu.com/v5/stock/chart/kline.json?symbol="+gcodeArray[_index]+"&begin=1582878803954&period=month&type=before&count=-9999&indicator=kline,pe,pb,ps,pcf,market_capital,agt,ggt,balance;")
                if(gcodeArray[_index])
                    changeUrl("https://stock.xueqiu.com/v5/stock/chart/kline.json?symbol="+gcodeArray[_index]+"&begin=1582878803954&period=month&type=before&count=-9999&indicator=kline,pe,pb,ps,pcf,market_capital,agt,ggt,balance;")

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
                    Storage.initialize();
                    //console.log("https://stock.xueqiu.com/v5/stock/chart/kline.json?symbol="+gcodeArray[_index]+"&begin=1582878803954&period=month&type=before&count=-9999&indicator=kline,pe,pb,ps,pcf,market_capital,agt,ggt,balance;")
                    changeUrl("https://stock.xueqiu.com/v5/stock/chart/kline.json?symbol="+gcodeArray[_index]+"&begin=1582878803954&period=month&type=before&count=-9999&indicator=kline,pe,pb,ps,pcf,market_capital,agt,ggt,balance;")
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
                text:"买卖点计算"
                onClicked: {
                    console.log("start sfx",cxcode)
                    getSdata()
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
                text:"概率选股"
                onClicked: {
                    console.log("start fx",seri,monthCount)
                    getAllData()
                    //                    getAllData2()
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
                text: "高点选股"
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
    function getLocationData()
    {

        console.log("start get from location")
        Storage.getAllSetting()
        console.log("get from location finish")
    }

    function getSdata()
    {
        var dataModel = gCodeMap[cxcode]
        getZhishu(dataModel);
    }

    function getZhishu(dataModel)
    {
        var max = 0
        var jun = 0
        var min = 0
        var curMonth = 0

        var index = 0
        if (dataModel.length > smonthCount)
        {
            index = dataModel.length - smonthCount
        }
        if (smonthCount == 0)
        {
            index = 0
        }

        for( var i = index; i < dataModel.length-1 ; ++i )
        {
            var item = dataModel[i]
            if(item.shou >max && item.shou > item.kai)
            {
                curMonth = i
                max = item.shou
                jun = item.jun
                min = item.min
            }
        }
        var dimax = Math.pow(max,(1/i) )
        console.log( "底max:",dimax,"下1", Math.pow(dimax, dataModel.length+1), "下2",Math.pow(dimax, dataModel.length+2), "下3",Math.pow(dimax, dataModel.length+3)  )
        var dijun = Math.pow(jun,(1/i) )
        console.log( "底jun:",dijun,"下1", Math.pow(dijun, dataModel.length+1), "下2",Math.pow(dijun, dataModel.length+2), "下3",Math.pow(dijun, dataModel.length+3)  )
        var dimin = Math.pow(min,(1/i) )
        console.log( "底min:",dimin,"下1", Math.pow(dimin, dataModel.length+1), "下2",Math.pow(dimin, dataModel.length+2), "下3",Math.pow(dimin, dataModel.length+3)  )
    }

    function getAllData2()
    {
        pb.from  = 0

        pb.to = gcodeArray.length-1
        for(var i = 0; i<gcodeArray.length-1; ++i)
        {
            var gcode = gcodeArray[i]
            var strModel = Storage.getSetting(gcode)
            if(strModel != "Unknown")
            {
                var dataModel = JSON.parse(strModel)
                var result = isUpDay(dataModel);
                if(result != -1)
                {
                    console.log(gcode, result)
                }
            }
            else
            {
                console.log("Unknown ", gcode)
            }
            pb.value = i

        }

    }

    function getAllData()
    {

        for(var key in gCodeMap){

            var dataModel = gCodeMap[key]
            var result = isUpDay(dataModel);
            if(result != -1)
            {
                console.log(key, result)
            }
        }
    }

    function isUpDay(dataModel)
    {
        var updayCount = 0;

        if (monthCount < dataModel.length)
        {
            var index = dataModel.length - monthCount
            if (monthCount == 0)
            {
                index = monthCount
            }

            for( var i = index; i < dataModel.length-1 ; ++i )
            {
                var item = dataModel[i]
                if(item.shou-item.kai >0)
                {
                    updayCount++
                }
            }
        }
        //        console.log(updayCount/dataModel.length, updayCount, dataModel.length)
        var xseri = updayCount/dataModel.length
        if(  xseri>= seri && dataModel.length > 36)
            return xseri
        else
            return -1
    }

    function getMaxArray( dataModel , index , status)
    {


        if(index == dataModel.count-2)
        {
            return;
        }

        if ( status == true )
        {
            var tempJun = dataModel.get(index).jun;;
            for( var i = index; i < dataModel.count-1 ; ++i )
            {
                var item = dataModel.get(i)
                if(tempJun < item.jun)
                {
                    index = i;
                    tempJun = item.jun
                }
                if( tempJun > item.jun)
                {
                    index = i
                    console.log( "Max", dataModel.get(i-1).date, dataModel.get(i-1).max, dataModel.get(i-1).min)
                    status = false; // 切换状态
                    break;
                }

            }
        }
        else{
            var tempJun = dataModel.get(index).jun;
            for( var i = index; i < dataModel.count-1 ; ++i )
            {
                var item = dataModel.get(i)
                if(tempJun > item.jun)
                {
                    tempJun = item.jun
                    index = i
                }
                if( tempJun < item.jun)
                {
                    index = i
                    console.log( "Min", dataModel.get(i-1).date, dataModel.get(i-1).max, dataModel.get(i-1).min)
                    status = true; // 切换状态
                    break;
                }
                //                index = i;
            }
        }
        getMaxArray(dataModel, index, status)
    }

    function getMinArray( dataModel )
    {

    }

    // 递归获取月线
    function getSignalMonthData(i){
        //        console.log("get Data:",gcodeArray[i]);
        XmlHttpRequest.ajax("GET","http://data.gtimg.cn/flashdata/hushen/monthly/"+gcodeArray[i]+".js?maxage=43201",function(xhr){

            if(xhr.status == 200)
            {
                //                console.log("get SUCCESS")
                var data = xhr.responseText;
                datafactory(data, gcodeArray[i]);
                if(i < gcodeArray.length)
                {
                    getSignalMonthData(++i);
                }
                else
                {
                    console.log("finish")
                    return
                }
            }
            else{
                console.log("http://data.gtimg.cn/flashdata/hushen/monthly/"+gcodeArray[i]+".js?maxage=43201");
                console.log("get ERROR")
                if(i < gcodeArray.length)
                {
                    getSignalMonthData(++i);
                }
                else
                {
                    console.log("finish")
                    return
                }
            }
        });
    }


    // 数据工厂
    function datafactory(dataArray, gcode)
    {
        try{
            if(dataArray != null)
            {

                var dataModel = new Array()
                for(var i=0; i <dataArray.length; ++i)
                {
                    var dataInfo = dataArray[i];
                    if(dataInfo.length > 6)
                    {
                        dataModel.push({
                                           date:  dataInfo[0],
                                           kai:   Number(dataInfo[2]),
                                           shou:  Number(dataInfo[5]),
                                           max:   Number(dataInfo[3]),
                                           min:   Number(dataInfo[4]),
                                           liang: dataInfo[1],
                                           jun:   (Number(dataInfo[2]) + Number(dataInfo[5])) / 2
                                       })
                    }
                }
                console.log(gcode,Storage.setSetting(gcode,JSON.stringify(dataModel)))
                //                console.log(gcode,JSON.stringify(dataModel))
            }
        }catch(e)
        {
            console.log(e)
        }
    }
}
