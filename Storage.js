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
                    tx.executeSql('CREATE TABLE IF NOT EXISTS msetSetting(setting TEXT UNIQUE, value TEXT)');
                });
}
function initializeD() {
    var db = getDatabase();
    db.transaction(
                function(tx) {
                    // 如果setting表不存在，则创建一个
                    // 如果表存在，则跳过此步
                    tx.executeSql('CREATE TABLE IF NOT EXISTS dsetSetting(setting TEXT UNIQUE, value TEXT)');
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
                    initialize()
                });
}
function deleteDataBaseD()
{
    var db = getDatabase();
    db.transaction(
                function(tx) {
                    // 如果setting表不存在，则创建一个
                    // 如果表存在，则跳过此步
                    tx.executeSql('DROP TABLE settings');
                    initialize()
                });
}
// 插入数据
function setSetting(setting, value) {
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO msetSetting VALUES (?,?);', [setting,value]);
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

// 插入数据
function setSettingD(setting, value) {
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO dsetSetting VALUES (?,?);', [setting,value]);
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
        var res="";
        var rs = tx.executeSql('SELECT * FROM msetSetting;');
        if (rs.rows.length > 0) {
            for(var i =0; i < rs.rows.length; ++i)
            {
                var gcode = rs.rows.item(i).setting;
                var value = rs.rows.item(i).value;
                var dataModel = JSON.parse(value)
                //                console.info(gcode, value)
                if(dataModel!=null)
                    gCodeMap[gcode] = dataModel
            }
        } else {
            res = "Unknown";

        }
    })
}
function getAllSettingD()
{
    var db = getDatabase();
    db.transaction(function(tx) {
        var res="";
        var rs = tx.executeSql('SELECT * FROM dsetSetting;');
        if (rs.rows.length > 0) {
            for(var i =0; i < rs.rows.length; ++i)
            {
                var gcode = rs.rows.item(i).setting;
                var value = rs.rows.item(i).value;
                var dataModel = JSON.parse(value)
                //                console.info(gcode, value)
                if(dataModel!=null)
                    gCodeMapD[gcode] = dataModel
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
        var rs = tx.executeSql('SELECT value FROM msetSetting WHERE setting=?;', [setting]);
        if (rs.rows.length > 0) {
            res = rs.rows.item(0).value;
        } else {
            res = "Unknown";
        }
    })
    return res
}

// 获取数据
function getSettingD(setting) {
    var db = getDatabase();
    var res="";
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT value FROM dsetSetting WHERE setting=?;', [setting]);
        if (rs.rows.length > 0) {
            res = rs.rows.item(0).value;
        } else {
            res = "Unknown";
        }
    })
    return res
}

function getKLine(code, type)
{
    return r_netrequest.getKLine(code, type)
}

// 扫描振幅相似度
function scanGz()
{
    gListModel.clear()
    var value001 = getKLine("SH000001", "day" )
    for(var i = 0; i <gcodeArray.length; ++i)
    {
        var value = getKLine(gcodeArray[i], "day" )
        compare001(value001, value)
    }
}

function compare001(value001, value)
{
    var obj001 = JSON.parse(value001 )
    var data001 = obj001.data;
    var obj = JSON.parse(value )
    var data = obj.data;
    if(!!data)
    {
        var symbol = data.symbol
        var column = data.column
        var item = data.item
        var item001 = data001.item


        var totalCount = item.length


        var maxCount = 0
        var count = 0;
        var start = parseInt(totalCount/2)
        var countInfo = []
        var cday = 30// totalCount
        for(var i = totalCount-cday; i < totalCount-1; ++i)
        {
            var time = item[i+1][0]
            var open = item[i+1][2]
            var close = item[i+1][5]
            var time001 = item001[i][0]
            var open001 = item001[i][2]
            var close001 = item001[i][5]
            if( (close > open  && close001 > open001  )||(close < open  && close001  < open001  ) || (close === open  && close001 === open001 ))
            {
                count++
            }
            //            else
            //            {
            //                if(maxCount < count)
            //                    maxCount = count
            //                if(count > 0)
            //                    countInfo.push({"count":count})
            //                count = 0
            //            }
        }
        if(count/cday >= 0.73)
        {
            //            gListModel.append({
            //                                  _code:symbol.toLowerCase(),
            //                                  _seri: count/totalCount
            //                              })
            console.info("symbol:",symbol,"maxCount:",maxCount,"totalCount:",cday, count/cday * 100,"%",JSON.stringify(countInfo))
        }
    }
}


function findYaLiMax()
{

    for(var i = 0; i <gcodeArray.length; ++i)
    {
        var value = getKLine(gcodeArray[i], "month" )
        calYaLiMax(value, gnameArray[i])
    }

}

function findYaLi()
{

    for(var i = 0; i <gcodeArray.length; ++i)
    {
        var value = getKLine(gcodeArray[i], "day" )
        calYaLi(value)
    }

}

// JDSF
function calYaLiMax(value, name)
{
    try
    {
    var obj = JSON.parse(value )
    var data = obj.data;
    var oneDay = 86400000
    if(!!data)
    {
        var symbol = data.symbol
        var column = data.column
        var item = data.item
        if(symbol === undefined)
            return

        var newCount = 0;
        var totalCount = item.length
        var newMax = 0;
        if(!!item)
        {
            var isUp = true
            var _top = -1
            var _bottom = -1
            var time = item[totalCount-1][0]
            var time1 = item[totalCount-2][0]
            var heigh0 = item[totalCount-1][2] > item[totalCount-1][5] ? item[totalCount-1][2] : item[totalCount-1][5]
            var heigh01 = item[totalCount-2][2] > item[totalCount-2][5] ? item[totalCount-2][2] : item[totalCount-2][5]

            var lower = item[totalCount-1][2] < item[totalCount-1][5] ? item[totalCount-1][2] : item[totalCount-1][5]
            var lower1 = item[totalCount-2][2] < item[totalCount-2][5] ? item[totalCount-2][2] : item[totalCount-2][5]

            isUp = heigh01 > heigh0
            if(isUp === true)
                _top = heigh01
            else
                _bottom = heigh0


            var lowerTime = 0;
            var maxTop = -1
             var time0
            if(totalCount < 48)
                return
            for(var i = totalCount-2; i > 1; --i)
            {

                var time01 = item[i-1][0]
                var open = item[i][2]
                var close = item[i][5]
                var open1 = item[i-1][2]
                var close1 = item[i-1][5]

                var heigh = open > close ? open : close
                var heigh1 = open1 > close1 ? open1 : close1
                lower = open < close ?  open : close
                lower1 = open1 < close1 ? open1 : close1

                if(isUp === true) // up
                {
                    if(heigh1 > heigh)
                    {
                        _top = heigh1
                    }
                    else
                    {



                        //console.info(symbol," Yali:", new Date(time0).toLocaleString(Qt.locale("de_DE"), "yyyy-MM-dd HH:mm:ss"),"bottom:",_bottom )
                        if(maxTop === -1)
                        {
                            if(heigh01 > _top)
                            {
                                time0 = time
                                maxTop = heigh01

                            }
                            else
                            {
                                time0 = item[i][0]
                                maxTop = _top
                            }

                        }
                        if(maxTop < _top)
                            return
                    }

                }
                else // down
                {
                    if(heigh1 > heigh)
                    {
                        //console.info(symbol," ZhiCheng:", new Date(time0).toLocaleString(Qt.locale("de_DE"), "yyyy-MM-dd HH:mm:ss"),"bottom:",_bottom )
                        isUp = true
                        lowerTime = time0
                    }
                    else
                    {
                        _bottom = lower1
                    }
                }

            }
            gListModel.append({
                                  _name: name,
                                  _code: symbol.toLowerCase(),
                                  _data: data,
                                  _seri: newCount/totalCount
                              })
            console.info(symbol,"find YaLi:", new Date(time0).toLocaleString(Qt.locale("de_DE"), "yyyy-MM-dd HH:mm:ss"),"top:",maxTop )
        }
    }
    }
    catch(e)
    {
    }
}


// JDSF
function calYaLi(value)
{
    var obj = JSON.parse(value )
    var data = obj.data;
    var oneDay = 86400000
    if(!!data)
    {
        var symbol = data.symbol
        var column = data.column
        var item = data.item
        if(symbol === undefined)
            return

        var newCount = 0;
        var totalCount = item.length
        var newMax = 0;
        if(!!item)
        {
            var isUp = true
            var _top = -1
            var _bottom = -1
            var time = item[totalCount-1][0]
            var time1 = item[totalCount-2][0]
            var heigh0 = item[totalCount-1][2] > item[totalCount-1][5] ? item[totalCount-1][2] : item[totalCount-1][5]
            var heigh01 = item[totalCount-2][2] > item[totalCount-2][5] ? item[totalCount-2][2] : item[totalCount-2][5]

            var lower = item[totalCount-1][2] < item[totalCount-1][5] ? item[totalCount-1][2] : item[totalCount-1][5]
            var lower1 = item[totalCount-2][2] < item[totalCount-2][5] ? item[totalCount-2][2] : item[totalCount-2][5]

            isUp = heigh01 > heigh0
            if(isUp === true)
                _top = heigh01
            else
                _bottom = heigh0


            var lowerTime = 0;

            for(var i = totalCount-2; i > 1; --i)
            {
                var time0 = item[i][0]
                var time01 = item[i-1][0]
                var open = item[i][2]
                var close = item[i][5]
                var open1 = item[i-1][2]
                var close1 = item[i-1][5]

                var heigh = open > close ? open : close
                var heigh1 = open1 > close1 ? open1 : close1
                lower = open < close ?  open : close
                lower1 = open1 < close1 ? open1 : close1

                if(isUp === true) // up
                {
                    if(heigh1 > heigh)
                    {
                        _top = heigh1
                    }
                    else
                    {
                        //console.info(symbol," YaLi:", new Date(time0).toLocaleString(Qt.locale("de_DE"), "yyyy-MM-dd HH:mm:ss"),"top:",_top )

                        if((time - lowerTime )/oneDay < 4 && heigh0 > _top && _top !== -1)
                        {
                            if(heigh0  - _top %heigh0  > 0.5 )
                            {
                                console.info("symbol:", symbol)
                                console.info((time - lowerTime )/oneDay, "Day Break",  _top, "time:",new Date(time0).toLocaleString(Qt.locale("de_DE") , "yyyy-MM-dd HH:mm:ss"),"Now:",heigh0 )
                            }
                            isUp = false

                        }
                        return
                    }

                }
                else // down
                {
                    if(heigh1 > heigh)
                    {
                        //console.info(symbol," ZhiCheng:", new Date(time0).toLocaleString(Qt.locale("de_DE"), "yyyy-MM-dd HH:mm:ss"),"bottom:",_bottom )
                        isUp = true
                        lowerTime = time0
                    }
                    else
                    {
                        _bottom = lower1
                    }
                }

            }
        }
    }
}

// 扫描日X
function scanKLines()
{
    gListModel.clear()
    for(var i = 0; i <gcodeArray.length; ++i)
    {
        var type = ""
        if(cday.checked)
            type = "day"
        if(cmonth.checked)
            type = "mounth"

        var value = getKLine(gcodeArray[i], type )
        scalDayNewTopCount(value)

    }
}

function scalDayNewTopCount(value)
{

    var obj = JSON.parse(value )
    var data = obj.data;
    if(!!data)
    {
        var symbol = data.symbol
        var column = data.column
        var item = data.item

        var newCount = 0;
        var totalCount = item.length
        var newMax = 0;
        if(!!item)
            for(var i = 0; i < totalCount; ++i)
            {
                var time = item[i][0]
                if(time < 1151827576000)
                    continue;
                var open = item[i][2]
                var close = item[i][5]
                if(close > open)
                {
                    if(close > newMax)
                    {
                        newMax = close
                        newCount++
                    }
                }
            }
        if(newCount/totalCount > 0.05)
        {
            gListModel.append({
                                  _code:symbol.toLowerCase(),
                                  _seri: newCount/totalCount
                              })
            console.info("symbol:",symbol,"newCount:",newCount,"totalCount:",totalCount, newCount/totalCount * 100,"%")
        }
    }
}

function calNewTop(status)
{
    gListModel.clear()

    for(var j = 0; j<gcodeArray.length-1; ++j)
    {

        var gcode = gcodeArray[j]
        var strModel = getSetting(gcode)
        if(strModel != "Unknown")
        {
            var dataModel = JSON.parse(strModel)
            if(dataModel!=null)
                gCodeMap[gcode] = dataModel
            var max = 0
            var curDay = 0
            if(status == 0)
            {
                for(  var i = dataModel.length -1; i >=0  ; --i )
                {
                    var item = dataModel[i]
                    if(item.jun >max )
                    {
                        curDay = dataModel.length-i
                        max = item.jun
                    }
                }
            }
            else if(status == 1)
            {
                for(  var i = 0; i < dataModel.length  ; ++i )
                {
                    var item = dataModel[i]
                    if(item.jun >max )
                    {
                        curDay = i
                        max = item.jun
                    }
                }
            }

            var s = curDay/dataModel.length
            if (s < serigao+0.01 && s >= serigao)
            {
                gListModel.append({
                                      _code:gcode.toLowerCase(),
                                      _seri: curDay/dataModel.length
                                  })
                console.log(gcode, "  ", curDay/dataModel.length)
            }
        }
        else
        {
            //            console.log("Unknown ", gcode)
        }

    }
}
