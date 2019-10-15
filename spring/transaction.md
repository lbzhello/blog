## Spring 事物实现原理

Spring 中的事物通过 aop 实现；而 aop 通过动态代理(jdk proxy, cglib)实现；动态代理通过 post-processor 机制实现。

关于 aop 实现机制可参考 [Spring AOP 实现原理](aop.md)

@EnableTransactionManagement 启用 spring 事物，通过 @Import 机制注册两个组件：

**AutoProxyRegistrar** 注册 post-processor 用来生成代理对象。

**ProxyTransactionManagementConfiguration** 配置了三个组件

1. BeanFactoryTransactionAttributeSourceAdvisor 增强器，对 bean 进行事物增强。持有 2 和 3

2. TransactionAttributeSource 管理事物定义（只读，回滚，隔离级别，传播行为），持有一个 TransactionAnnotationParser 用于解析 @Transactional 注解

3. TransactionInterceptor 事物拦截器，持有 2

