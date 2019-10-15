## Spring AOP 实现原理

## 什么是 aop

AOP (Aspect Oriented Programming) 面向切面编程，是不同于 OOP （面向对象编程） 的另一种软件设计思想。

OOP 强调的是继承，封装，多态; AOP 关注的是业务处理过程中的某个步骤或阶段

OOP 将事物抽象成具有某种属性和行为的对象，不同的对象具有不同的行为； AOP 将不同的行为中的相同步骤抽象成一个切面，进行统一的管理。

在一个软件系统中会有不同的业务处理模块，比如用户模块，订单模块，仓储模块，支付模块，不同的模块具有不同的功能（行为）：用户登录、下订单、仓储发货，支付等。 这些不同的行为具有相同的逻辑：在操作之前进行权限验证，操作之后进行日志记录，可能还需要事物控制，异常处理，性能统计等。当然可以在这些方法之前或之后进行单独的处理，但这样耦合性很大，不利于扩展和维护，更好的做法是将这些相同的逻辑分离出来，将这些相似的处理阶段（之前，之后）抽象成一个切面，进行统一的处理。这便是 AOP 所解决的问题。

## Spring AOP 实现

Spring 直接使用了 AspectJ 的注解，但并不是使用 AspectJ 的静态代理来实现的，而是通过动态代理。即 jdk 动态代理 或者 cglib 动态代理。如果对象实现了接口，则默认使用 jdk 动态代理, 否则使用 cglib 动态代理，当然这种行为是可以配置的。

需要注意的是 jdk 动态代理是基于接口代理的，如果对象没有实现接口，则无法使用 jdk 动态代理。而 cglib 是基于继承来实现的，如果对象不可继承（final），则不能使用 cglib.

Spring 通过 post-processor 机制实现动态代理，即在对象创建完成之后调用 postProcessAfterInitialization 方法，根据配置（PointCut, Advice 等）创建一个代理类返回给用户。

## AnnotationAwareAspectJAutoProxyCreator

### 启用 AOP

在配置类上加 @EnableAspectJAutoProxy 注解， 它通过 @Import 机制引入了一个 ImportBeanDefinitionRegistrar 的实现类 AspectJAutoProxyRegistrar，调用 registerBeanDefinition 方法注册 AOP 后处理器 AnnotationAwareAspectJAutoProxyCreator。xml 配置与此类似。

后处理逻辑在父类 AbstractAutoProxyCreator 中

> 下面是 java 伪码，只显示了主要的处理逻辑，详细的处理逻辑可以参考 spring 源码

### AbstractAutoProxyCreator#postProcessAfterInitialization

```java
public Object postProcessAfterInitialization(@Nullable Object bean, String beanName) throws BeansException {
    if (bean != null) {
        //格式：beanClassName_beanName, 作为代理类缓存名字
        Object cacheKey = getCacheKey(bean.getClass(), beanName);
        if (!this.earlyProxyReferences.contains(cacheKey)) {
            // 必要时创建增强
            return wrapIfNecessary(bean, beanName, cacheKey);
        }
    }
    return bean;
}

protected Object wrapIfNecessary(Object bean, String beanName, Object cacheKey) {
    
    /** 无需增强或者已经增强，直接返回 bean **/

    // 查找 bean 对应的增强 (Advice)
    Object[] specificInterceptors = getAdvicesAndAdvisorsForBean(bean.getClass(), beanName, null);
    if (specificInterceptors != DO_NOT_PROXY) {
        this.advisedBeans.put(cacheKey, Boolean.TRUE); // 需要增强
        // 创建代理
        Object proxy = createProxy(
                bean.getClass(), beanName, specificInterceptors, new SingletonTargetSource(bean));
        this.proxyTypes.put(cacheKey, proxy.getClass());
        return proxy;
    }

    // 标记无需增强
    this.advisedBeans.put(cacheKey, Boolean.FALSE);
    return bean;
}
```


