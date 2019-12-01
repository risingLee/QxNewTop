import QtQuick 2.6
import QtQuick.Window 2.2
import "xmlhttprequest.js" as XmlHttpRequest
Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")
    property var gcodeArray: ["sz000001"]//,"sz000002","sz000003"]
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
            getSignalMonthData(0)
            getAllData()
        }
    }

    function getAllData()
    {
        for(var key in gCodeMap){

            var dataModel = gCodeMap[key]
            getMaxArray(dataModel, 0, true)

        }
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
                    tempJun = item.jun
                }
                if( tempJun > item.jun)
                {
                    index = i
                    console.log( "Max", dataModel.get(i-1).date, dataModel.get(i-1).max, dataModel.get(i-1).min)
                    status = false; // 切换状态
                    break;
                }
                index = i;
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
                }
                if( tempJun < item.jun)
                {
                    index = i
                    console.log( "Min", dataModel.get(i-1).date, dataModel.get(i-1).max, dataModel.get(i-1).min)
                    status = true; // 切换状态
                    break;
                }
                index = i;
            }
        }
        getMaxArray(dataModel, index, status)
    }

    function getMinArray( dataModel )
    {

    }

    // 递归获取月线
    function getSignalMonthData(i){
        XmlHttpRequest.ajax("GET","http://data.gtimg.cn/flashdata/hushen/monthly/"+gcodeArray[i]+".js?maxage=43201",function(xhr){
            if(xhr.status == 200)
            {
                var data = xhr.responseText;
                datafactory(data, gcodeArray[i]);
                if(i < gcodeArray.length)
                {
                    getSignalMonthData(++i);
                }
                else
                {
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
                dataModel.clear();
                for(var i =1; i <dataArray.length -1; ++i)
                {
                    var lineData = dataArray[i].trim()
                    var dataInfo = lineData.split(" ");
                    if(dataInfo.length == 6)
                    {
                        dataModel.append({
                                            date:  dataInfo[0],
                                            kai:   dataInfo[1],
                                            cur:   dataInfo[2],
                                            max:   dataInfo[3],
                                            min:   dataInfo[4],
                                            liang: dataInfo[5],
                                            jun:   (Number(dataInfo[3]) + Number(dataInfo[4])) / 2
                                         })
                    }
                }
                gCodeMap[gcode] = dataModel
            }
        }catch(e)
        {
            console.log(e)
        }
    }
}
