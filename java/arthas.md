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
- dashboard 
展示当前进程的信息

- thread 1 
线程 ID 1 的栈信息

- jad demo.MathGame
反编译 demo.MathGame

- watch demo.MathGame primeFactors returnObj
查看 demo.MathGame#primeFactors 返回值

## 进阶使用
https://alibaba.github.io/arthas/advanced-use.html

## watch
```
# params 参数列表
# returnObj 返回值
# target 目标对象属性
# throwExp 异常信息 -e 参数有效
watch demo.MathGame primeFactors "{params,returnObj}" -x 2
```

-x 2 输出结果的属性遍历深度，默认为 1
-n 3 监听次数，达到次数自动关闭

## 异步执行

1. 使用&在后台执行任务
```
trace Test t &
```

2. 通过jobs查看任务

3. 任务暂停和取消
当任务正在前台执行，比如直接调用命令trace Test t或者调用后台执行命令trace Test t &后又通过fg命令将任务转到前台。这时console中无法继续执行命令，但是可以接收并处理以下事件：

‘ctrl + z’：将任务暂停。通过jbos查看任务状态将会变为Stopped，通过bg <job-id>或者fg <job-id>可让任务重新开始执行

‘ctrl + c’：停止任务

‘ctrl + d’：按照linux语义应当是退出终端，目前arthas中是空实现，不处理

4. fg、bg命令，将命令转到前台、后台继续执行
任务在后台执行或者暂停状态（ctrl + z暂停任务）时，执行fg <job-id>将可以把对应的任务转到前台继续执行。在前台执行时，无法在console中执行其他命令

当任务处于暂停状态时（ctrl + z暂停任务），执行bg <job-id>将可以把对应的任务在后台继续执行

非当前session创建的job，只能由当前session fg到前台执行

5. 任务输出重定向
可通过>或者>>将任务输出结果输出到指定的文件中，可以和&一起使用，实现arthas命令的后台异步任务。比如：

$ trace Test t >> test.out &
这时trace命令会在后台执行，并且把结果输出到~/logs/arthas-cache/test.out。可继续执行其他命令。并可查看文件中的命令执行结果。

当连接到远程的arthas server时，可能无法查看远程机器的文件，arthas同时支持了自动重定向到本地缓存路径。使用方法如下：

$ trace Test t >>  &
job id  : 2
cache location  : /Users/gehui/logs/arthas-cache/28198/2
可以看到并没有指定重定向文件位置，arthas自动重定向到缓存中了，执行命令后会输出job id和cache location。cache location就是重定向文件的路径，在系统logs目录下，路径包括pid和job id，避免和其他任务冲突。命令输出结果到/Users/gehui/logs/arthas-cache/28198/2中，job id为2。

6. 停止命令
异步执行的命令，如果希望停止，可执行kill

7. 其他
最多同时支持8个命令使用重定向将结果写日志

请勿同时开启过多的后台异步命令，以免对目标JVM性能造成影响

如果不想停止arthas，继续执行后台任务，可以执行 quit 退出arthas控制台（stop 会停止arthas 服务）

## 原理
基于 Instrument JVMTI 组件，可以以代理的方式访问和修改 java 虚拟机内部的数据 （171）