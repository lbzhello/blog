## SpringMVC 设计原理



## Servlet 规范

SpringMVC 是基于 Servlet 的。

Servlet 是一个规范，它只定义了 Servlet 容器在处理服务器请求时应该具有怎样的行为，具体如何实现这些行为由 Servlet 容器来决定。

Servlet 规范有三个主要的技术点： Servlet, Filter, Listener  

Servlet 是实现 Servlet 接口的程序，Servlet 规范规定它在 Servlet 容器启动时调用 init 方法，每次请求到来时调用 service 方法，Servlet 销毁时调用 destory 方法

Lister 是监听某个对象的状态变化的组件，是一种观察者模式。

被监听的对象可以是域对象 ServletContext, Session, Request

监听的内容可以是域对象的创建与销毁，域对象属性的变化

![servlet listernr](/img/spring/mvc/servlet-listener.png)

Filter 过滤器，用来拦截客户请求, 只有通过 Filter 的请求（如果有的话）才能被 Servlet 处理。它同样会在容器启动时调用 init 方法，每次请求到来时执行 doFilter 方法，Filter 销毁时执行 destory 方法。

Filter 可以通过配置（xml 或 java-based）拦截特定的请求，在 Servlet 执行前后（由 chain.doFilter 划分）处理特定的逻辑，如字符编码，日志打印，Session 处理等

## 主要类及其功能

SpringMVC 用 Spring 化的方式来管理 web 请求中的各种对象。

什么是 Spring 化？ IOC 和 AOP, 用它的方式，改写一部历史，这不是本文的重点，具体自行查阅。

SpringMVC 会通过 WebApplicationContext 来管理服务器请求中涉及到的各种对象和他们之间的依赖关系。我们不需要花费大量的精力去理清各种对象之间的复杂关系，而是以离散的形式专注于单独的功能点。

WebApplicationContext 继承自 ApplicationContext, 它定义了一些新的作用域、获取 ServletContext 的接口等信息。

SpringMVC 应用中几乎所有的类都交由 WebApplicationContext 管理，包括业务方面的 @Controller, @Service, @Repository 注解的类， DispatcherServlet ， 文件处理 multipartResolver, 视图解析器 ViewResolver, 处理器映射器 HandleMapping 等。

SpringMVC 可以通过两种方式创建 WebApplicationContext

一种是通过 ContextLoaderListener, 它创建的 WebApplicationContext 称为 root application context，或者说根容器。一个 ServletContext 中只能有一个根容器，而一个 web application 中只能有一个 ServletContext，因此一个 web 应用程序中只能有一个根容器

另一种是通过 DispatcherServlet, 它创建的 WebApplicationContext，称为上下文容器，上下文容器只在 DispatcherServlet 范围内有效。DispatcherServlet 就是一个 Servlet，因此可以有多个 DispatcherServlet，也就可以有多个上下文容器。**但是一般情况下没必要这样做**，多个 
DispatcherServlet 不会降低耦合性，但却增加了复杂性。

如果当前 ServletContext 存在根容器并且它没有父容器，就会把根容器设为它的父容器。




```java
```

SpringMVC 有两种方式创建 WebApplicationContext，一种 

一般我们会配置（web.xml 或 java-based）一个 org.springframework.web.context.ContextLoaderListener, 它实现了 ServletContextListener 接口, 根据 Servelet 规范，这个 Listener 会在 ServletContext 创建时执行 ServletContextListener#contextInitialized. 

相关代码如下：
```java
@Override
public void contextInitialized(ServletContextEvent event) {
    initWebApplicationContext(event.getServletContext());
}
```

ContextLoader#initWebApplicationContext 

```java
/**
 * Initialize Spring's web application context for the given servlet context,
 * using the application context provided at construction time, or creating a new one
 * according to the "{@link #CONTEXT_CLASS_PARAM contextClass}" and
 * "{@link #CONFIG_LOCATION_PARAM contextConfigLocation}" context-params.
 * @param servletContext current servlet context
 * @return the new WebApplicationContext
 * @see #ContextLoader(WebApplicationContext)
 * @see #CONTEXT_CLASS_PARAM
 * @see #CONFIG_LOCATION_PARAM
 */
public WebApplicationContext initWebApplicationContext(ServletContext servletContext) {
    if (servletContext.getAttribute(WebApplicationContext.ROOT_WEB_APPLICATION_CONTEXT_ATTRIBUTE) != null) {
        throw new IllegalStateException(
                "Cannot initialize context because there is already a root application context present - " +
                "check whether you have multiple ContextLoader* definitions in your web.xml!");
    }

    servletContext.log("Initializing Spring root WebApplicationContext");
    Log logger = LogFactory.getLog(ContextLoader.class);
    if (logger.isInfoEnabled()) {
        logger.info("Root WebApplicationContext: initialization started");
    }
    long startTime = System.currentTimeMillis();

    try {
        // Store context in local instance variable, to guarantee that
        // it is available on ServletContext shutdown.
        if (this.context == null) {
            this.context = createWebApplicationContext(servletContext);
        }
        if (this.context instanceof ConfigurableWebApplicationContext) {
            ConfigurableWebApplicationContext cwac = (ConfigurableWebApplicationContext) this.context;
            if (!cwac.isActive()) {
                // The context has not yet been refreshed -> provide services such as
                // setting the parent context, setting the application context id, etc
                if (cwac.getParent() == null) {
                    // The context instance was injected without an explicit parent ->
                    // determine parent for root web application context, if any.
                    ApplicationContext parent = loadParentContext(servletContext);
                    cwac.setParent(parent);
                }
                configureAndRefreshWebApplicationContext(cwac, servletContext);
            }
        }
        servletContext.setAttribute(WebApplicationContext.ROOT_WEB_APPLICATION_CONTEXT_ATTRIBUTE, this.context);

        ClassLoader ccl = Thread.currentThread().getContextClassLoader();
        if (ccl == ContextLoader.class.getClassLoader()) {
            currentContext = this.context;
        }
        else if (ccl != null) {
            currentContextPerThread.put(ccl, this.context);
        }

        if (logger.isInfoEnabled()) {
            long elapsedTime = System.currentTimeMillis() - startTime;
            logger.info("Root WebApplicationContext initialized in " + elapsedTime + " ms");
        }

        return this.context;
    }
    catch (RuntimeException | Error ex) {
        logger.error("Context initialization failed", ex);
        servletContext.setAttribute(WebApplicationContext.ROOT_WEB_APPLICATION_CONTEXT_ATTRIBUTE, ex);
        throw ex;
    }
}

```

它先判断当前 ServletContext 中是否已经存在 WebApplicationContext. 如果存在则报错，否则判断 context(指 Spring 的 WebApplicationContext) 是否为 null，这里分两种情况：

#### 1. context != null  
ContextLoaderListener 有一个参数 WebApplicationContext 的构造方法，如果创建的时候提供了这个 context 则下面不需要再创建一个 context，这个构造方法在 java config 的方式会用到，下面会说到

#### 2. context == null  
这种情况一般是通过 web.xml 方式配置的 ContextLoaderListener。

若 context == null, 调用 ContextLoader#createWebApplicationContext 创建一个 WebApplicationContext 并将它放在 ServletContext 上下文中，以 `WebApplicationContext.ROOT_WEB_APPLICATION_CONTEXT_ATTRIBUTE` 为 key. 因此可以调用 ```servletContext.getAttribute(WebApplicationContext.ROOT_WEB_APPLICATION_CONTEXT_ATTRIBUTE)``` 拿到这个 WebApplicationContext, 更简单的方法是通过 SpringMVC 提供的工具类 ```WebApplicationContextUtils.getWebApplicationContext(servletContext)``` 

ContextLoader#createWebApplicationContext 创建 WebApplicationContext

```java
protected WebApplicationContext createWebApplicationContext(ServletContext sc) {
    Class<?> contextClass = determineContextClass(sc);
    if (!ConfigurableWebApplicationContext.class.isAssignableFrom(contextClass)) {
        throw new ApplicationContextException("Custom context class [" + contextClass.getName() +
                "] is not of type [" + ConfigurableWebApplicationContext.class.getName() + "]");
    }
    return (ConfigurableWebApplicationContext) BeanUtils.instantiateClass(contextClass);
}

```
ContextLoader#determineContextClass 根据 ```ContextLoader.CONTEXT_CLASS_PARAM``` 确定使用哪个 WebApplicationContext 的实现类，即我们在 web.xml 中配置的初始化参数 contextClass。

```java
protected Class<?> determineContextClass(ServletContext servletContext) {
    String contextClassName = servletContext.getInitParameter(CONTEXT_CLASS_PARAM);
    if (contextClassName != null) {
        try {
            return ClassUtils.forName(contextClassName, ClassUtils.getDefaultClassLoader());
        }
        catch (ClassNotFoundException ex) {
            throw new ApplicationContextException(
                    "Failed to load custom context class [" + contextClassName + "]", ex);
        }
    }
    else {
        contextClassName = defaultStrategies.getProperty(WebApplicationContext.class.getName());
        try {
            return ClassUtils.forName(contextClassName, ContextLoader.class.getClassLoader());
        }
        catch (ClassNotFoundException ex) {
            throw new ApplicationContextException(
                    "Failed to load default context class [" + contextClassName + "]", ex);
        }
    }
}
```
若 contextClass 未指定，则从 defaultStrategies 这个 Properties 中获取，他默认加载 ClassPath 路径下， ContextLoader.properties 文件中配置的类，默认为 XmlWebApplicationContext。

```java
```

到这里 WebApplicationContext 已经创建完成

WebApplicationContext 创建完成之后接着设置 parent, 子类可以通过模版方法 loadParentContext(servletContext) 配置 web 上下文的层次结构。

和 Spring 的 ApplicationContext 一样，基于配置文件方式的 WebApplicationContext 也需要一个 bean 的配置文件，执行 refresh 等操作。这些操作由 refresh 完成

```java
```

## java config 

## Java Config

```java
public class MyWebAppInitializer extends AbstractAnnotationConfigDispatcherServletInitializer {

    @Override
    protected Class<?>[] getRootConfigClasses() {
        return null;
    }

    @Override
    protected Class<?>[] getServletConfigClasses() {
        return new Class<?>[] { MyWebConfig.class };
    }

    @Override
    protected String[] getServletMappings() {
        return new String[] { "/" };
    }
}
```

WebApplicationInitializer

![WebApplicationInitializer](/img/spring/mvc/web-application-initializer.png)



参考：
1. [servlet监听器Listener介绍和使用][1]  
2. [UML各种图总结-精华][2]

[1]: https://blog.csdn.net/qq_15204179/article/details/82055448

[2]: https://www.cnblogs.com/jiangds/p/6596595.html