


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
            if(cmonth.checked)
                console.log(gcode,Storage.setSetting(gcode,JSON.stringify(dataModel)))
            if(cday.checked)
                console.log(gcode,Storage.setSettingD(gcode,JSON.stringify(dataModel)))
            //                console.log(gcode,JSON.stringify(dataModel))
        }
    }catch(e)
    {
        console.log(e)
    }
}
