## Content-Type

#### application/x-www-form-urlencoded 
From 表单默认类型, 如果不设置 enctype 默认为此形式提交数据。类似于这种形式

```
POST http://www.example.com HTTP/1.1 
Content-Type: application/x-www-form-urlencoded;charset=utf-8 

title=test&sub%5B%5D=1&sub%5B%5D=2&sub%5B%5D=3 
```
请求体按照 key1=val1&key2=val2 这种方式
进行 URL 转码

#### multipart/form-data 
使用表单上传文件时，必须让 form 的 enctype 等于此值

格式如下
```
POST http://www.example.com HTTP/1.1 
Content-Type:multipart/form-data; boundary=----WebKitFormBoundaryrGKCBY7qhFd3TrwA 

------WebKitFormBoundaryrGKCBY7qhFd3TrwA 
Content-Disposition: form-data; name="text" 

title 
------WebKitFormBoundaryrGKCBY7qhFd3TrwA 
Content-Disposition: form-data; name="file"; filename="chrome.png" 
Content-Type: image/png 

PNG ... content of chrome.png ... 
------WebKitFormBoundaryrGKCBY7qhFd3TrwA-- 
```

boundary 指定的字符串用于分割不同的部分。如果传输的是文件，还会包含文件名和文件类型信息。消息主体最后以 --boundary-- 标示结束

#### application/json 
标识请求体是一个 json 编码的字符串，特别适合 RESTful 的接口

格式如下
```
POST http://www.example.com HTTP/1.1 
Content-Type: application/json;charset=utf-8 

{"title":"test","sub":[1,2,3]} 
```

#### text/xml
标识请求体是 xml 格式，如下所示

```
POST http://www.example.com HTTP/1.1 
Content-Type: text/xml 

<!--?xml version="1.0"?--> 
<methodcall> 
    <methodname>examples.getStateName</methodname> 
    <params> 
        <param> 
            <value><i4>41</i4></value> 
         
    </params> 
</methodcall> 
```