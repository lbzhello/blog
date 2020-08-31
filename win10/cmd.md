## 网络 tcp/ip

```sh
# 擦看端口占用
netstat -ano

# 查找指定端口
netstat -ano |findstr "端口号"

# 杀死进程
taskkill -pid 8080 -f

# 查看到对应的进程id之后，就可以通过id查找对应的进程名称，使用命令
tasklist | findstr "进程id号"
```

