# Spring Cache

## @Cacheable

- value redis 缓存中的 key
- cacheNames: 同 value
- key: 通过 spel 生成的 key
- sync 再多线程环境中，key 可能被计算多次（或多次访问 db），sync = true 可以有效的避免缓存击穿的问题

**关于 value 和 key 的区别**  

在 redis, 中，相当于调用 redis 的 set 函数, 那么生成的 Key 为 value 和 key 俩个字符串通过::进行连接


[spring cache 学习 —— @Cacheable 使用详解](https://www.cnblogs.com/coding-one/p/12401630.html)