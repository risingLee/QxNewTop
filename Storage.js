.import QtQuick.LocalStorage 2.0 as Sql
function getDatabase() {
    return Sql.LocalStorage.openDatabaseSync("MyAppName", "1.0", "StorageDatabase", 100000);
}

// 程序打开时，初始化表
function initialize() {
    var db = getDatabase();
    db.transaction(
                function(tx) {
                    // 如果setting表不存在，则创建一个
                    // 如果表存在，则跳过此步
                    tx.executeSql('CREATE TABLE IF NOT EXISTS settings(setting TEXT UNIQUE, value TEXT)');
                });
}

function deleteDataBase()
{
    var db = getDatabase();
    db.transaction(
                function(tx) {
                    // 如果setting表不存在，则创建一个
                    // 如果表存在，则跳过此步
                    tx.executeSql('DROP TABLE settings');
                });
}

// 插入数据
function setSetting(setting, value) {
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO settings VALUES (?,?);', [setting,value]);
        //console.log(rs.rowsAffected)
        if (rs.rowsAffected > 0) {
            res = "OK";
        } else {
            res = "Error";
        }
    }
    );
    return res;
}

function getAllSetting()
{
    var db = getDatabase();
    db.transaction(function(tx) {

        var rs = tx.executeSql('SELECT * FROM settings;');
        if (rs.rows.length > 0) {
            for(var i =0; i < rs.rows.length; ++i)
            {
                var gcode = rs.rows.item(i).setting;
                var value = rs.rows.item(i).value;
                var dataModel = JSON.parse(value)
                if(dataModel!=null)
                    gCodeMap[gcode] = dataModel
            }
        } else {
            res = "Unknown";
        }
    })
}

// 获取数据
function getSetting(setting) {
    var db = getDatabase();
    var res="";
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT value FROM settings WHERE setting=?;', [setting]);
        if (rs.rows.length > 0) {
            res = rs.rows.item(0).value;
        } else {
            res = "Unknown";
        }
    })
    return res
}

function getLocationData()
{

    console.log("start get from location")
//        Storage.getSettings(gcodeArray)
   getAllSetting()
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



    chartsview.newLine1.axisX.min = index
    chartsview.newLine1.axisY.min = index
    chartsview.newLine1.axisX.max = dataModel.length
    chartsview.newLine1.name = "shou"
    chartsview.newLine1.color  = "#8AB846"
    chartsview.newLine1.clear();

    chartsview.newLine2.axisX.min = index
    chartsview.newLine2.axisY.min = index
    chartsview.newLine2.axisX.max = dataModel.length
    chartsview.newLine2.name = "jun"
    chartsview.newLine2.color  ="#FFD52B1E"
    chartsview.newLine2.clear();

    chartsview.newLine3.axisX.min = index
    chartsview.newLine3.axisY.min = index
    chartsview.newLine3.axisX.max = dataModel.length
    chartsview.newLine3.name = "min"
    chartsview.newLine3.color  = "#FF0039A5"
    chartsview.newLine3.clear();
    var _max = 0
    var i = index
    for(  i = index; i < dataModel.length-1 ; ++i )
    {
        var item = dataModel[i]
        if (_max < item.shou)
        {
            _max = item.shou
            chartsview.newLine1.axisY.max = _max
            chartsview.newLine2.axisY.max = _max
            chartsview.newLine3.axisY.max = _max
        }
        chartsview.newLine1.append(i,item.shou);//向线条加点
        chartsview.newLine2.append(i,item.jun);
        chartsview.newLine3.append(i,item.min);
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
        var strModel = getSetting(gcode)
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
            console.log(gcode,setSetting(gcode,JSON.stringify(dataModel)))
            //                console.log(gcode,JSON.stringify(dataModel))
        }
    }catch(e)
    {
        console.log(e)
    }
}
