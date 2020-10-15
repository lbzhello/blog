## 下载文件名乱码问题
对文件名进行编码
```java
// iso-8859-1 编码大部分浏览器都支持
String encodedName = filename.getBytes("utf-8"),"iso-8859-1");
// 或者
String encodedName = URLEncoder.encode(filename,"UTF-8");

```

## setCharacterEncoding 和 setContentType 区别

1. response.setContentType 指定 HTTP 响应（内容）的编码, 

2. response.setCharacterEncoding 设置 HTTP 响应的编码, 如果之前使用 response.setContentType 设置了编码格式,则使用 response.setCharacterEncoding 指定的编码格式覆盖之前的设置.

## Error parsing HTTP request header java.io.EOFException: null

http 头缓冲区太小，设置 

server. maxHttpHeaderSize=32KB

## GET POST
那么，GET和POST的区别和应用？这问题挺复杂。简而言之，就是“安全”和“不安全”的区别。什么是安全？不用承担责任。什么是不安全？可能需要承担责任。**GET应该用于安全请求的规范。**

[关于在GET请求中使用body](https://blog.csdn.net/HermitSun/article/details/89889743)
HTTP 并未规定不可以 GET 中发送 Body