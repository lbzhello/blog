## Annotation 创建 bean 流程

## Bean 创建流程

#### Java Config 配置

```java
public class AnnotationApplication {
    public static void main(String[] args) {
        ApplicationContext context = new AnnotationConfigApplicationContext(JavaConfig.class);
        Foo foo = context.getBean(Foo.class);
        foo.bar();
    }
}
```

AnnotationConfigApplicationContext 构造方法

```java
public AnnotationConfigApplicationContext(Class<?>... annotatedClasses) {
    this();
    register(annotatedClasses);
    refresh();
}
```
#### 调用无参构造方法

```java
// 此方法同时会调用父类的无参构造方法创建 DefaultListableBeanFactory
public AnnotationConfigApplicationContext() {
    // 自身作为作为 registry 注册中心
    this.reader = new AnnotatedBeanDefinitionReader(this);
    this.scanner = new ClassPathBeanDefinitionScanner(this);
}
```

**AnnotatedBeanDefinitionReader** 提供 register 方法将 bean 注册到容器中。

此构造方法会调用 AnnotationConfigUtils.registerAnnotationConfigProcessors(this.registry) 注册基本的 post-processors, 这些 post-processors 会在 AbstractApplicationContext#refresh() 阶段起作用，关于 [post-processor](#post-processor) 下面会说到

**ClassPathBeanDefinitionScanner** 用于扫描 classpath 下符合条件的 bean，将其注册到 bean 容器。 符合条件的 bean 有： 

**Spring 注解的 bean**  
- @Component  
- @Repository  
- @Service  
- @Controller  

**JavaEE 注解的 bean**
- @ManagedBean
- @Named

#### register 
register 方法最终会调用 AnnotatedBeanDefinitionReader 的 doRegisterBean 方法

```java
<T> void doRegisterBean(Class<T> annotatedClass, @Nullable Supplier<T> instanceSupplier, @Nullable String name,
        @Nullable Class<? extends Annotation>[] qualifiers, BeanDefinitionCustomizer... definitionCustomizers) {
    // 创建 BeanDefinition，
    // 从 class 中提取 AnnotationMetadata 相关信息
    AnnotatedGenericBeanDefinition abd = new AnnotatedGenericBeanDefinition(annotatedClass);

    // 根据 @Conditional 相关注解判断是否注册 bean
    if (this.conditionEvaluator.shouldSkip(abd.getMetadata())) {
        return;
    }

    abd.setInstanceSupplier(instanceSupplier);

    // 根据 @Scope 注解确定 bean 作用域，默认为 singleton
    ScopeMetadata scopeMetadata = this.scopeMetadataResolver.resolveScopeMetadata(abd);
    abd.setScope(scopeMetadata.getScopeName());
    String beanName = (name != null ? name : this.beanNameGenerator.generateBeanName(abd, this.registry));

    // 处理 @Lazy、@Primary、@DependsOn、@Role、@Description
    AnnotationConfigUtils.processCommonDefinitionAnnotations(abd);
    if (qualifiers != null) {
        for (Class<? extends Annotation> qualifier : qualifiers) {
            if (Primary.class == qualifier) {
                abd.setPrimary(true);
            }
            else if (Lazy.class == qualifier) {
                abd.setLazyInit(true);
            }
            else {
                abd.addQualifier(new AutowireCandidateQualifier(qualifier));
            }
        }
    }
    for (BeanDefinitionCustomizer customizer : definitionCustomizers) {
        customizer.customize(abd);
    }

    // BeanDefinitionHolder 包含 bean definition 和别名
    BeanDefinitionHolder definitionHolder = new BeanDefinitionHolder(abd, beanName);
    definitionHolder = AnnotationConfigUtils.applyScopedProxyMode(scopeMetadata, definitionHolder, this.registry);
    // 注册 bean definition 到 registry
    BeanDefinitionReaderUtils.registerBeanDefinition(definitionHolder, this.registry);
}
```

#### refresh

```java
public void refresh() throws BeansException, IllegalStateException {
    synchronized (this.startupShutdownMonitor) {
        // Prepare this context for refreshing.
        prepareRefresh();

        // Tell the subclass to refresh the internal bean factory.
        ConfigurableListableBeanFactory beanFactory = obtainFreshBeanFactory();

        // Prepare the bean factory for use in this context.
        prepareBeanFactory(beanFactory);

        try {
            // Allows post-processing of the bean factory in context subclasses.
            postProcessBeanFactory(beanFactory);

            // Invoke factory processors registered as beans in the context.
            invokeBeanFactoryPostProcessors(beanFactory);

            // Register bean processors that intercept bean creation.
            registerBeanPostProcessors(beanFactory);

            // Initialize message source for this context.
            initMessageSource();

            // Initialize event multicaster for this context.
            initApplicationEventMulticaster();

            // Initialize other special beans in specific context subclasses.
            onRefresh();

            // Check for listener beans and register them.
            registerListeners();

            // Instantiate all remaining (non-lazy-init) singletons.
            finishBeanFactoryInitialization(beanFactory);

            // Last step: publish corresponding event.
            finishRefresh();
        }

        catch (BeansException ex) {
            if (logger.isWarnEnabled()) {
                logger.warn("Exception encountered during context initialization - " +
                        "cancelling refresh attempt: " + ex);
            }

            // Destroy already created singletons to avoid dangling resources.
            destroyBeans();

            // Reset 'active' flag.
            cancelRefresh(ex);

            // Propagate exception to caller.
            throw ex;
        }

        finally {
            // Reset common introspection caches in Spring's core, since we
            // might not ever need metadata for singleton beans anymore...
            resetCommonCaches();
        }
    }
}
```

1. 调用 prepareRefresh() refresh的准备阶段。
2. 获取 beanFactory，这个 beanFactory 是 AnnotationConfigApplicationContext 调用无参构造方法时，调用父类无参构造方法 GenericApplicationContext() 时创建的 DefaultListableBeanFactory，并不是 AnnotationConfigApplicationContext 自身。

```java
public GenericApplicationContext() {
    this.beanFactory = new DefaultListableBeanFactory();
}
```

3. 调用 prepareBeanFactory(beanFactory)。这个方法配置了 beanFactory 的基本功能，比如设置了 ClassLoader, 注册了一些 BeanPostProcesser, 默认的 environment 等
4. 调用 postProcessBeanFactory(beanFactory) 模板方法，可以用来定制 bean
5. 调用 invokeBeanFactoryPostProcessors(beanFactory) 实例化并且调用 BeanFactoryPostProcessor
6. 调用 registerBeanPostProcessors(beanFactory) 注册 BeanPostProcessor
7. 调用 initMessageSource() 初始化 message source 
8. 调用 initApplicationEventMulticaster() 初始化 event multicaster 
9. 调用 onRefresh() 模板方法。在实例化 singletons 之前定制一些类的行为
10. registerListeners()
11. finishBeanFactoryInitialization(beanFactory) 初始化非延迟加载的单例 bean
12. finishRefresh() 发布相应的事件

-----------

1. DefaultBeanDefinitionDocumentReader 解析 Xml Bean 标签定义的 Bean
processBeanDefinition

### @Configuration 注解 @Bean 方法返回的类在 invokeBeanFactoryPostProcessors 阶段注册到 beanFactory 中

org.springframework.context.annotation.internalConfigurationAnnotationProcessor = ConfigurationClassPostProcessor
AnnotationConfigUtils.registerAnnotationConfigProcessors

#### @Configuration 等注解支持构造参数注入

<span id="post-processor"></span>
## Post Processor

- **ConfigurationClassPostProcessor** 是一个 BeanFactoryPostProcess, 用来处理 @Configuration 相关注解，比如 @Bean, @Import, @ImportResource, @ComponentScan 等

- **AutowiredAnnotationBeanPostProcessor** BeanPostProcessor 实现类，看名字就知道是用来处理自动装配的，主要是 @Autowired, @Value, @Inject, @Lookup