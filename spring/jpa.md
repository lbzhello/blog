[Spring Data JPA 基本使用](https://www.cnblogs.com/chenglc/p/11226693.html)

## @EnableJpaRepositories 
加载指定包下所有集成 Repository 接口的 bean 到容器

## @EntityScan
加载指定包下所有 @Entity 注解的 bean 到容器

**注意：**
springboot 基于自动配置，如果启动类位于根目录下，则不需要 @EnableJpaRepositories @EntityScan 注解

## 继承关系

- @Entity A 继承 @Entity B
保存 A 时各自的字段保存在各自的表中，查询 A 时会查出两张表的并集。

- @Entity A 继承 非 @Entity B
只会保存 A 的数据到 A 表

- @Entity A 继承 @MappedSuperclass B
保存 A 时会将继承自 B 的字段同时保存到 A; B 不会生成表信息

##
[SpringBoot中JPA的基本使用](https://blog.csdn.net/weixin_39020878/article/details/110008230)
