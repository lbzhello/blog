[通过实例理解Java网络IO模型](https://blog.51cto.com/nxlhero/2442628)

## Scanner 

#### next() 和 nextLine() 区别
next() 读取到空白字符结束；nextLine() 读取换行符结束；

## 怎样理解阻塞非阻塞与同步异步的区别？
https://www.zhihu.com/question/19732473
IO 概念区分
四个相关概念：

同步（Synchronous）
异步( Asynchronous)
阻塞( Blocking )
非阻塞( Nonblocking)

这是两对概念，用在不同的语境会有一些不同的含义，不能一概而论。

整体来说，同步就是两种东西通过一种机制实现步调一致，异步是两种东西不必步调一致。

同步是两个对象之间的关系，而阻塞是一个对象的状态

[原创：同步与异步、阻塞与非阻塞](https://www.cnblogs.com/albert1017/p/3914149.html)