import QtQuick 2.6
import QtQuick.Controls 2.2

import QtQuick.Window 2.2
import "xmlhttprequest.js" as XmlHttpRequest
import "Storage.js" as Storage
Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")
    property var gcodeArray: g_lstData//["sz000001","sz000002","sz000003"]//
    property var cxcode: "sz300357"
    property var yearCount: 5
    property var monthCount: yearCount*12
    property var smonthCount: 71
    property var seri: 0.5
    property var gCodeMap: null




    Component.onCompleted:
    {
        gCodeMap = {}

        getLocationData()
    }

    Column
    {
        ProgressBar
        {
            id: pb
            width: 600
            height: 30

        }

        Row
        {
            Button
            {
                id: btnSet
                text:"requestData"
                onClicked:{
                    console.log("start",gcodeArray.length)
                    Storage.initialize();
                    getSignalMonthData(0)
                    console.log("stop")
                }
            }

            Button
            {
                id: btnDel
                text:"deleteDb"
                onClicked: {
                    Storage.deleteDataBase()
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
                text:"fenxData"
                onClicked: {
                    console.log("start fx",seri,monthCount)
                    getAllData()
//                    getAllData2()
                    console.log("fx finish")
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
                    text: "71"
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
                text:"fxgp"
                onClicked: {
                    console.log("start sfx",cxcode)
                    getSdata()
                    console.log("sfx finish")
                }
            }
        }
    }
    function getLocationData()
    {

        console.log("start get from location")
//        Storage.getSettings(gcodeArray)
       Storage.getAllSetting()
//        for(var i = 0; i<gcodeArray.length-1; ++i)
//        {
//            var gcode = gcodeArray[i]
//            var strModel = Storage.getSetting(gcode)
//            if(strModel != "Unknown")
//            {
//                var dataModel = JSON.parse(strModel)
//                if(dataModel!=null)
//                    gCodeMap[gcode] = dataModel
//            }
//            else
//            {
//                console.log("Unknown ", gcode)
//            }
//            pb.value = i
//        }

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
    function datafactory(data, gcode)
    {
        try{
            if(data != null)
            {
                var dataArray = data.split('\\n\\');
                var dataModel = new Array()
                for(var i =1; i <dataArray.length -1; ++i)
                {
                    var lineData = dataArray[i].trim()
                    var dataInfo = lineData.split(" ");
                    if(dataInfo.length == 6)
                    {
                        dataModel.push({
                                           date:  dataInfo[0],
                                           kai:   Number(dataInfo[1]),
                                           shou:  Number(dataInfo[2]),
                                           max:   Number(dataInfo[3]),
                                           min:   Number(dataInfo[4]),
                                           liang: dataInfo[5],
                                           jun:   (Number(dataInfo[2]) + Number(dataInfo[1])) / 2
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
