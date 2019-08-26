#### JMM 内存模型

线程之间的通信机制以后两种：共享内存和消息传递。

Java 采用共享内存方式进行多线程之间的通信。

JMM 控制 Java 多线程之间的通信方式，JMM 决定一个线程对共享变量的写入何时对另一个线程可见，JMM 定义了线程和主内存之间的抽象关系。

Java 内存模型中，共享变量（对象，数组）存储在主内存，线程执行时将主内存的共享变量读到**本地内存**，本地内存是一个抽象概念，涵盖了缓存，写缓冲区，寄存器，编译器优化等，操作完成后再将本地内存中共享变量的副本写回主内存。线程操作的是共享变量在本地内存中的副本，而不是共享变量本身。

这样就会遇到一些问题。线程读写的是本地内存中共享变量的副本，如果在此期间，变量被其他线程修改了怎么办？线程修改了共享变量，要不要立即把他同步到主内存中？这些问题最终都是线程间通信的问题。

#### happend-before 规则




1. 不要将锁的获取过程放在 try 快中，因为如果要获取锁(自定义锁的实现)时发生了异常，异常抛出的同时，也会导致锁无故的释放。

2. volatile 的**写-读**和锁的**释放-获取**具有相同的内存语义。

> 助记： volatile 读 -> getState -> 获取锁

3. 锁释放或 volatile 写操作， JMM 会把该线程对应的本地内存中的共享变量值刷新到主内存。

4. 锁获取或 volatile 读操作， JMM 会把该线程对应的本地内存置为无效。线程接下来将从主内存中读取共享变量。

5. 这里的写-读和释放-获取指的是 A 线程释放锁或写 volatile， 然后 B 线程获取锁或读 volatile。

6. CAS 同时具有 volatile 读和写的内存语义。

## AQS

模板方法

tryAcquire()
tryRelease()

tryAcquireShared()
tryReleaseShared()

isHeldExclusively() 

#### 实现

#### 获取排它锁

```java
public final void acquire(int arg) {
    if (!tryAcquire(arg) &&
        // addWaiter 构造列将节点添加到队列尾部
        // acquireQueued 循环、阻塞当前线程，直到唤醒或中断
        acquireQueued(addWaiter(Node.EXCLUSIVE), arg))
        // acquireQueued 返回中断标志，用来响应中断
        selfInterrupt();
}
```

#### 获取共享锁

```java
public final void acquireShared(int arg) {
    if (tryAcquireShared(arg) < 0)
        // 循环、阻塞获取共享锁
        doAcquireShared(arg);
}
```

#### 释放排它锁

```java
public final boolean release(int arg) {
    if (tryRelease(arg)) {
        Node h = head;
        if (h != null && h.waitStatus != 0)
            // 唤醒下一个线程
            unparkSuccessor(h);
        return true;
    }
    return false;
}
```

#### 释放共享锁

```java
public final boolean releaseShared(int arg) {
    if (tryReleaseShared(arg)) {
        doReleaseShared();
        return true;
    }
    return false;
}
```