# Daemon 线程（守护线程）

Daemon 线程用于服务用户线程，守护线程创建的过程中需要先调用 setDaemon 方法进行设置,然后再启动线程

#### 【特点】
- 当用户线程运行结束的时候, Daemon 线程将会自动退出
- Daemon 线程创建的子线程任然是 Daemon 线程

## https://segmentfault.com/a/1190000038255460