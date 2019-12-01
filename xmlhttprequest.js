//通过Json对象输出url的query字符串
  function urlQuery(jsonObject) {
        var query = "";
        var i = 0;
        for(var iter in jsonObject) {

            if(i > 0) {
                query += "&";
            }
            query += iter +"=" + encodeURI(jsonObject[iter]);
            i++;
        }
        // console.log("url query:", query);
        return query;
    }
    //设置头
    function setHeader(xhr, headers) {
        //"Content-Type":"application/x-www-form-urlencoded"
        for(var iter in headers) {
            xhr.setRequestHeader(iter, headers[iter]);
        }
    }
    //这里我修改了一下函数的形参，从使用的角度来看，回调函数一般都会有，但是headers不一定要设置，所以调换了一下位置
    function ajax(method, url, callable,headers,data) {
        headers = headers || {};
        callable = callable || function(xhr) {
            console.log("没有设置callable，使用默认log函数")
            console.log(xhr.status);
            console.log(xhr.responseText);
        }
        var xhr = new XMLHttpRequest;
        xhr.onreadystatechange = function() {
            if(xhr.readyState == xhr.DONE) {
                callable(xhr);
            }
        }
        xhr.open(method, url);
        setHeader(xhr, headers);
        if("GET" === method) {
            xhr.send();
        } else {
            xhr.send(data);
        }
    }
