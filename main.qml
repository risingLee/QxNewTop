import QtQuick 2.6
import QtQuick.Controls 2.2

import QtCharts 2.2

import QtQuick.Window 2.2
import "Storage.js" as Storage
import "xmlhttprequest.js" as XmlHttpRequest

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
        Storage.initialize()
//        Storage.getLocationData()
    }

    // 递归获取Month
    function getSignalMonthData(i){
        //        console.log("get Data:",gcodeArray[i]);
        XmlHttpRequest.ajax("GET","http://data.gtimg.cn/flashdata/hushen/monthly/"+gcodeArray[i]+".js?maxage=43201",function(xhr){

            if(xhr.status == 200)
            {
                //                console.log("get SUCCESS")
                var data = xhr.responseText;
                Storage.datafactory(data, gcodeArray[i]);
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
    // 递归获取Month
    function getSignalDayData(i){
        //        console.log("get Data:",gcodeArray[i]);
        pb.value = i
        XmlHttpRequest.ajax("GET","http://finance.sina.com.cn/realstock/company/"+gcodeArray[i]+"/qianfuquan.js?d=2000-06-16",function(xhr){


            if(xhr.status == 200)
            {
                //                console.log("get SUCCESS")
                var data = xhr.responseText;

                Storage.datafactory2(data, gcodeArray[i]);
                if(i < gcodeArray.length)
                {
                    getSignalDayData(++i);
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
                    getSignalDayData(++i);
                }
                else
                {
                    console.log("finish")
                    return
                }
            }
        });
    }
    Column
    {
        anchors.fill: parent
        ChartView {
            id: chartsview;
            width: 400
            height: 300

            visible: true
            theme: ChartView.ChartThemeBrownSand
            antialiasing: true

            ValueAxis{
                id: axiasX;
                max: 500;
                min: 0;
            }

            ValueAxis{
                id: axiasY;
                max: 200;
                min: 0;
            }


            property var newLine1 : chartsview.createSeries(ChartView.SeriesTypeLine,"1");
            property var newLine2 : chartsview.createSeries(ChartView.SeriesTypeLine,"2");
            property var newLine3 : chartsview.createSeries(ChartView.SeriesTypeLine,"3");
            Component.onCompleted: {

            }
        }

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
//                    getSignalMonthData(0)
                    pb.from  = 0
                    pb.to = gcodeArray.length-1
                    getSignalDayData(0)
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

                    Storage.getAllData()
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
                    text: "sh603338"
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
                    var strModel = Storage.getSetting(cxcode)
                    if(strModel != "Unknown")
                    {
                        var dataModel = JSON.parse(strModel)
                        if(dataModel!=null)
                            gCodeMap[cxcode] = dataModel
                    }
                    else
                    {
                        console.log("Unknown ", cxcode)
                    }
//                    Storage.getSdata()

                    Storage.getSDayData()
                    console.log("sfx finish")
                }
            }
        }
    }


}
