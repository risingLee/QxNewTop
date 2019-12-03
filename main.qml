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
    property var yearCount: 5
    property var monthCount: yearCount*12
    property var seri: 0.5
    property var gCodeMap: null
    ListModel
    {
        id: dataModel
    }

    Component.onCompleted:
    {
        gCodeMap = {}
    }
    MouseArea {
        anchors.fill: parent
        onClicked: {

            getAllData()
        }
    }
    Button
    {
        id: btnSet
        text:"requestData"

        onClicked:{
            console.log("start")
            Storage.initialize();
            getSignalMonthData(0)
            console.log("stop")
        }

    }
    Button
    {
        id: btnGet
        text:"getLocationData"
        anchors.left:btnSet.right
        onClicked: {
            console.log("start get from location")
//            console.log(Storage.getSetting("sz600276"))
            for(var i = 0; i<gcodeArray.length-1; ++i)
            {
                var gcode = gcodeArray[i]
                var strModel = Storage.getSetting(gcode)
                if(strModel != "Unknown")
                {
                    var dataModel = JSON.parse(strModel)
                    if(dataModel!=null)
                        gCodeMap[gcode] = dataModel
                }
                else
                {
                    console.log("Unknown ", gcode)
                }
            }
            console.log("get from location finish")
        }
    }
    Button
    {
        id: benDel
        text:"deleteDb"
        anchors.top: btnSet.bottom
        onClicked: {
           Storage.deleteDataBase()
        }
    }

    Button
    {
        id: btnFenx
        text:"fenxData"
        anchors.left:btnGet.right
        onClicked: {
            console.log("start fx",seri,monthCount)
            getAllData()
            console.log("fx finish")
        }
    }

    Rectangle
    {
        id: txSeri
        width: 100
        height: 30
        anchors.left:btnFenx.right
        anchors.margins: 20
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
        anchors.left:txSeri.right
        anchors.margins: 20
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
                                           jun:   (Number(dataInfo[3]) + Number(dataInfo[4])) / 2
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
