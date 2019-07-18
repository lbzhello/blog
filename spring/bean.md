## Annotation 创建 bean 流程

## 主要接口及其功能

#### ApplicationContext

#### BeanDefinition

 bean定义接口
1. AnnotatedBeanDefinition 额外提供 AnnotationMetadata 信息

## Bean 创建流程

#### Java Config 方式

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
#### 1. 调用无参构造方法

```java
public AnnotationConfigApplicationContext() {
    this.reader = new AnnotatedBeanDefinitionReader(this);
    this.scanner = new ClassPathBeanDefinitionScanner(this);
}
```

它会创建一个 reder 和 scanner 用于显示注册或扫描 classpath 下符合条件的bean，将其注册到 bean 容器(BeanFactory 或 ApplicationContext)。

> **AnnotatedBeanDefinitionReader** 用于 annotated bean 的显示注册。即通过掉用 register 方法直接将 bean(比如 @Configuration 注解的配置类)注册到容器中。
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

#### 2. register 
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
1. 将 bean 封装成 AnnotatedGenericBeanDefinition，它继承自 BeanDefinition，并额外提供了 AnnotationMetadata 相关支持。下面的 bean 表示此 beanDefition。
2. 通过 conditionEvaluator 判断是否注册 bean。它根据 @Conditional 相关注解管理 bean 创建的先后关系。
3. 调用 scopeMetadataResolver 根据 @Scope 注解确定 bean 作用域，默认为 singleton。 
4. 确定 beanName，如果指定名字直接返回，否则调用 beanNameGenerator 生成一个 name。
5. 调用 AnnotationConfigUtils.processCommonDefinitionAnnotations 处理部分通用注解。比如 @Lazy、@Primary、@DependsOn、@Role、@Description。
6. 调用 BeanDefinitionCustomizer 处理 bean
7. 将 bean 封装成 BeanDefinitionHolder，提供 bean 名字、别名信息。下面 bean 表示 definitionHolder。
8. 调用 BeanDefinitionReaderUtils.registerBeanDefinition 将 bean 注册到 registry，registry 是 BeanDefinitionRegistry 的实现类，它会调用自身的 registerBeanDefinition 方法注册 beanDefinition。

#### 3. refresh

