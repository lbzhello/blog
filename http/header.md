## [Transfer-Encoding: chunked](https://www.cnblogs.com/micro-chen/p/7183275.html)
分块传输，最后一个快长度为零，表示传输结束 1.1 规范，无法知道 Content-Length 的情况下判断传输结束

## pragma: no-cache （http 1.0 提供）和 Cache-Control: no-cache （http 1.1 提供）
强制页面不缓存

## Content-Length: 233
说明 http 请求体大小

当启用了 Collection: KeepAlive，那么一个 socket(tcp) 可以发送多次请求，那么如何判断每次的响应已经接收?

1. 先读请求头，一直到\r\n\r\n说明请求头结束，然后解析http头，如果Content-Length=x存在，则知道http响应的长度为x。直接读取x字节就是响应内容。

2. 如果Content-Length: x不存在，那么头类型为Transfer-Encoding: chunked说明响应的长度不固定，则在响应头结束后标记第一段流的长度

如果采用短连接，则直接可以通过服务器关闭连接来确定消息的传输长度。（这个很容易懂）

Http1.1之前的不支持keep alive。那么可以得出以下结论：
1. 在Http 1.0及之前版本中，content-length字段可有可无。
2. 在http1.1及之后版本。如果是keep alive，则content-length和chunk必然是二选一。若是非keep alive，则和http1.0一样。content-length可有可无

## Transfer-Encoding: chunked