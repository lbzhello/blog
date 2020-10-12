## 参考

put函数大致的思路为：

对key的hashCode()做hash，然后再计算index;
如果没碰撞直接放到bucket里；
如果碰撞了，以链表的形式存在buckets后；
如果碰撞导致链表过长(大于等于TREEIFY_THRESHOLD)，就把链表转换成红黑树；
如果节点已经存在就替换old value(保证key的唯一性)
如果bucket满了(超过load factor*current capacity)，就要resize。

[jdk1.8 HashMap工作原理与power of two offset利用](https://blog.csdn.net/qq_26222859/article/details/80669361)