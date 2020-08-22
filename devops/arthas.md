# 入门

- 启动一个 demo 作为测试
curl -O https://arthas.aliyun.com/arthas-demo.jar
java -jar arthas-demo.jar

- 下载启动
curl -O https://arthas.aliyun.com/arthas-boot.jar
java -jar arthas-boot.jar

```
$ $ java -jar arthas-boot.jar
* [1]: 35542
  [2]: 71560 arthas-demo.jar

```

输入 2 选择刚刚启动的 demo 进程，若成功 attach 进程，控制台显示如下：

```
[INFO] Try to attach process 32916
[INFO] Found java home from System Env JAVA_HOME: C:\Program Files\Java
[INFO] Attach process 32916 success.
[INFO] arthas-client connect 127.0.0.1 3658
  ,---.  ,------. ,--------.,--.  ,--.  ,---.   ,---.
 /  O  \ |  .--. ''--.  .--'|  '--'  | /  O  \ '   .-'
|  .-.  ||  '--'.'   |  |   |  .--.  ||  .-.  |`.  `-.
|  | |  ||  |\  \    |  |   |  |  |  ||  | |  |.-'    |
`--' `--'`--' '--'   `--'   `--'  `--'`--' `--'`-----'


wiki      https://arthas.aliyun.com/doc
tutorials https://arthas.aliyun.com/doc/arthas-tutorials.html
version   3.3.9
pid       32916
time      2020-08-22 16:48:00

[arthas@32916]$ 
```

## 命令
- dashboard 展示当前进程的信息

- thread 1 线程 ID 1 的栈信息
