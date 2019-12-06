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
                    initialize()
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
        console.log("==insert setting:",res)
    }
    );
    return res;
}

function getAllSetting()
{
    var db = getDatabase();
    db.transaction(function(tx) {
        var res="";
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
            console.log(res)
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

function calNewTop(status)
{
//    gListModel.clear()
    console.log(gcodeArray.length)
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
//                gListModel.append({
//                                      _code:gcode,
//                                      _seri: curDay/dataModel.length
//                                  })
                console.log(gcode, "  ", curDay/dataModel.length)
            }
        }
        else
        {
//            console.log("Unknown ", gcode)
        }

    }
}
