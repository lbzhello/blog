# curl 指南
curl 命令详解可参见 [curl](https://jaywcjlove.gitee.io/linux-command/c/curl.html)

## 网络访问

```sh
# -d 'name=foo&pwd=bar' 发送 post 请求, 可以写成 -d 'name=foo' -d 'pwd=bar' 这种形式
# -d '@data.txt' POST 文件中的数据; -d '{"user": "foo", "pwd": "123"}' json 格式
# -H 'content-type: application/json' 添加请求头
# -X POST 发送 post 请求，其他同理
# -c cookies.txt 将 cookie 写入文件
# -b cookies.txt 携带文件中的 cookie，见上
# -b 'user=root;pass=123456' 携带 cookie，多个用 ',' 分割
# -i 包括头信息； -I 只显示头信息
# -L 自动重定向
# -v 显示请求全过程解析
# -k 不会检查服务器的 SSL 证书是否正确，有时候会出现 SSL certificate problem，可以加上此参数
curl URL
```

## 文件下载

```sh
# -O 表示以源文件命名
# -o fileName 指定一个文件名
# -s --silent 不输出错误和进度信息
curl -O URL
```

## 登录认证

```sh
# -u 可以完成HTTP或者FTP的认证，可以指定密码，也可以不指定密码在后续操作中输入密码
curl -u user:pwd http://example.com
curl -u user http://example.com
```

## 