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

##