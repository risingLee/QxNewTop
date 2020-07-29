﻿.import QtQuick.LocalStorage 2.0 as Sql
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

function getDayKLine(code, type)
{
    return r_netrequest.getKLine(code, type)
}

// 扫描振幅相似度
function scanGz()
{
    gListModel.clear()
    var value001 = getDayKLine("SH000001", "day" )
    for(var i = 0; i <gcodeArray.length; ++i)
    {

        if(gcodeArray[i].indexOf("SH")>-1)
        {
            var value = getDayKLine(gcodeArray[i], "day" )
            compare001(value001, value)
        }

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
        for(var i = 0; i < totalCount; ++i)
        {
            var time = item[i][0]
            var open = item[i][2]
            var close = item[i][5]
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
        if(count/totalCount > 0.8)
        {
//            gListModel.append({
//                                  _code:symbol.toLowerCase(),
//                                  _seri: count/totalCount
//                              })
            console.info("symbol:",symbol,"maxCount:",maxCount,"totalCount:",totalCount, count/totalCount * 100,"%",JSON.stringify(countInfo))
        }
    }
}

// 扫描日线
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

        var value = getDayKLine(gcodeArray[i], type )
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
