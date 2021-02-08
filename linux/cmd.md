[linux command](https://jaywcjlove.gitee.io/linux-command/)

## tar -zxvf somefile.tar.gz -C targetdir --strip-components 1

-v 显示解压过程
--strip-components n 去除文件层级 n

## curl 

## tail
tail -f xxx.log 实时打印出最新的变动

## 运维

## 搜索
1. find

```sh
# 列出当前目录及子目录下所有文件和文件夹
find . 

# 默认当前目录，同 find .
find

# 在当前目录查找名字以 .txt 结尾的文件
find . -name "*.txt"
```

# 网络

## 查看端口占用情况

```sh
netstat -ano | grep 端口号
```
**参数**
- a 显示所有连接中的端口


## 端口是否可通
```sh
telnet ip port

# 占用
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.
Connection closed by foreign host.

# 不通
Trying 127.0.0.1...
telnet: connect to address 127.0.0.1: Connection refused

```

## 端口被那个进程占用
```sh
# 端口 8080 被 PID 26305 进程占用 
netstat -tunlp | grep 8080
tcp6       0      0 :::8080                 :::*                    LISTEN      26305/java
```


# 进程

```sh
# 强制结束 26305 进程
kill -9 26305
```