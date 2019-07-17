## Annotation 创建 bean 流程

#### BeanDefinition bean定义接口，
1. AnnotatedBeanDefinition 额外提供 AnnotationMetadata 信息

## Bean创建流程

#### Java Config 方式 Bean 创建

```java
ApplicationContext context = new AnnotationConfigApplicationContext(JavaConfig.class);

HelloWorld helloWorld = context.getBean(HelloWorld.class);

helloWorld.say();
```

调用 AnnotationConfigApplicationContext 构造方法创建一个 ApplicationContext

```java
public AnnotationConfigApplicationContext(Class<?>... annotatedClasses) {
    this();
    register(annotatedClasses);
    refresh();
}
```

先调用无参构造方法

```java
public AnnotationConfigApplicationContext() {
    this.reader = new AnnotatedBeanDefinitionReader(this);
    this.scanner = new ClassPathBeanDefinitionScanner(this);
}
```

它会创建一个 reder 和 scanner 用于显示注册或扫描 classpath 下符合条件的bean，将其注册到 bean 容器(BeanFactory 或 ApplicationContext)。

> **AnnotatedBeanDefinitionReader** 用于 annotated bean 的显示注册。即通过掉用 register 方法直接将 bean(一般是 @Configuration 注解的配置类)注册到容器中。
>  
> **ClassPathBeanDefinitionScanner** 用于扫描 classpath 下符合条件的 bean，将其注册到 bean 容器。 默认符合条件的 bean 有：  
> - **Spring 注解的 bean**  
>   - @Component  
>   - @Repository  
>   - @Service  
>   - @Controller  
>
> - **JavaEE 注解的 bean**
>   - @ManagedBean
>   - @Named

register 方法最终会调用 AnnotatedBeanDefinitionReader 的 doRegisterBean 方法

```java
<T> void doRegisterBean(Class<T> annotatedClass, @Nullable Supplier<T> instanceSupplier, @Nullable String name,
        @Nullable Class<? extends Annotation>[] qualifiers, BeanDefinitionCustomizer... definitionCustomizers) {

    AnnotatedGenericBeanDefinition abd = new AnnotatedGenericBeanDefinition(annotatedClass);
    if (this.conditionEvaluator.shouldSkip(abd.getMetadata())) {
        return;
    }

    abd.setInstanceSupplier(instanceSupplier);
    ScopeMetadata scopeMetadata = this.scopeMetadataResolver.resolveScopeMetadata(abd);
    abd.setScope(scopeMetadata.getScopeName());
    String beanName = (name != null ? name : this.beanNameGenerator.generateBeanName(abd, this.registry));

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

    BeanDefinitionHolder definitionHolder = new BeanDefinitionHolder(abd, beanName);
    definitionHolder = AnnotationConfigUtils.applyScopedProxyMode(scopeMetadata, definitionHolder, this.registry);
    BeanDefinitionReaderUtils.registerBeanDefinition(definitionHolder, this.registry);
}
```

其过程大致是：  
1. 根据提供的 bean 创建一个创建一个 AnnotatedGenericBeanDefinition，它继承自 BeanDefinition，并额外提供了 AnnotationMetadata 相关支持。