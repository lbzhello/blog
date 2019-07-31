## SpringMVC 设计原理



## Servlet 规范

SpringMVC 是基于 Servlet 的。

Servlet 是一个规范，它只定义了 Servlet 容器在处理服务器请求时应该具有怎样的行为，具体如何实现这些行为由 Servlet 容器来决定。

Servlet 规范有三个主要的技术点： Servlet, Filter, Listener  

Servlet 是实现 Servlet 接口的程序，Servlet 规范规定它在 Servlet 加载时调用 init 方法，每次请求到来时调用 service 方法，Servlet 销毁时调用 destory 方法

Servlet 可以配置在容器启动时加载或者请求第一次到来时加载，但无论怎样都只会被初始化一次；可以为不同的 URL 配置不同的 Servlet

Lister 是监听某个对象的状态变化的组件，是一种观察者模式。

被监听的对象可以是域对象 ServletContext, Session, Request

监听的内容可以是域对象的创建与销毁，域对象属性的变化

![servlet listernr](/img/spring/mvc/servlet-listener.png)

Filter 过滤器，用来拦截客户请求, 只有通过 Filter 的请求（如果有的话）才能被 Servlet 处理。它同样会在容器启动时调用 init 方法，每次请求到来时执行 doFilter 方法，Filter 销毁时执行 destory 方法。

Filter 可以通过配置（xml 或 java-based）拦截特定的请求，在 Servlet 执行前后（由 chain.doFilter 划分）处理特定的逻辑，如字符编码，日志打印，Session 处理等

## Servlet 的配置与 SpringMVC 的实现

#### 通过 web.xml
这个是以前常用的配置方式。Servlet 容器会在启动时加载根路径下 /WEB-INF/web.xml 配置文件。根据其中的配置加载 Servlet, Listener, Filter 等。下面是 SpringMVC 的常见配置：

```xml
```

其启动流程大致是这样的,下面会详细分析

![spring-mvc-xml]()

#### 通过 ServletContainerInitializer
这个是 Servlet 3.0 的规范，新的 code-based 的配置方式。简单来说就是容器会去加载文件JAR包下 META-INF/services/javax.servlet.ServletContainerInitalizer 文件中声明的 ServletContainerInitalizer（SCI） 实现类，并调用他的 onStartup 方法，可以通过 @HandlesTypes 注解将特定的 class 添加到 SCI。

在 spring-web 模块下有个文件 META-INF/services/javax.servlet.ServletContainerInitalizer

![sci]()

SpringServletContainerInitalizer

```java

```

它会探测并加载 ClassPath 下 **WebApplicationContextInitializer** 的实现类，调用它的 onStartUp 方法。比如 SpringMVC 的 java-based 配置方式：

```java

```

更简单的方法是继承 AbstractAnnotationConfigDispatcherServletInitializer

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

其启动过程如下，下面会详细分析

![spring-mvc-xml]()

## Servlet 和 WebApplicationContext

SpringMVC 用 Spring 化的方式来管理 web 请求中的各种对象。

什么是 Spring 化？ IOC 和 AOP, 用它的方式，改写一部历史，这不是本文的重点，具体自行查阅。

SpringMVC 会通过 WebApplicationContext 来管理服务器请求中涉及到的各种对象和他们之间的依赖关系。我们不需要花费大量的精力去理清各种对象之间的复杂关系，而是以离散的形式专注于单独的功能点。

WebApplicationContext 继承自 ApplicationContext, 它定义了一些新的作用域、获取 ServletContext 的接口等信息。

```java
public interface WebApplicationContext extends ApplicationContext {

	//根容器名，作为 key 存储在 ServletContext 中; ServletContextListener 创建的 WebApplicationContext
	String ROOT_WEB_APPLICATION_CONTEXT_ATTRIBUTE = WebApplicationContext.class.getName() + ".ROOT";

	/**
	 * 这三个是 WebApplicationContext 所特有的作用域
     * 通过 WebApplicationContextUtils.registerWebApplicationScopes 注册相应的处理器
	 */
	String SCOPE_REQUEST = "request";
	String SCOPE_SESSION = "session";
	String SCOPE_APPLICATION = "application";

	/**
	 * ServletContext 在 WebApplicationContext 中的名字
     * 因此除了用 getServletContext() 方法获取到 ServletContext 外
     * 还可以根据此 key 获取到
     * 通过 WebApplicationContextUtils.registerEnvironmentBeans 注册到 WebApplicationContext 中
	 */
	String SERVLET_CONTEXT_BEAN_NAME = "servletContext";

	/**
	 * Name of the ServletContext init-params environment bean in the factory.
	 * <p>Note: Possibly merged with ServletConfig parameters.
	 * ServletConfig parameters override ServletContext parameters of the same name.
	 * @see javax.servlet.ServletContext#getInitParameterNames()
	 * @see javax.servlet.ServletContext#getInitParameter(String)
	 * @see javax.servlet.ServletConfig#getInitParameterNames()
	 * @see javax.servlet.ServletConfig#getInitParameter(String)
	 */
	String CONTEXT_PARAMETERS_BEAN_NAME = "contextParameters";

	/**
	 * Name of the ServletContext attributes environment bean in the factory.
	 * @see javax.servlet.ServletContext#getAttributeNames()
	 * @see javax.servlet.ServletContext#getAttribute(String)
	 */
	String CONTEXT_ATTRIBUTES_BEAN_NAME = "contextAttributes";


	/**
	 * Return the standard Servlet API ServletContext for this application.
	 */
	@Nullable
	ServletContext getServletContext();

}
```

SpringMVC 应用中几乎所有的类都交由 WebApplicationContext 管理，包括业务方面的 @Controller, @Service, @Repository 注解的类， ServletContext, 文件处理 multipartResolver, 视图解析器 ViewResolver, 处理器映射器 HandleMapping 等。

SpringMVC 可以通过两种方式创建 WebApplicationContext

一种是通过 ContextLoaderListener, 它创建的 WebApplicationContext 称为 root application context，或者说根容器。一个 ServletContext 中只能有一个根容器，而一个 web application 中只能有一个 ServletContext，因此一个 web 应用程序中只能有一个根容器，**根容器不是必要的**。

另一种是通过 DispatcherServlet, 它创建的 WebApplicationContext，称为上下文容器，上下文容器只在 DispatcherServlet 范围内有效。DispatcherServlet 本质上是一个 Servlet，因此可以有多个 DispatcherServlet，也就可以有多个上下文容器。**但是一般情况下没必要这样做**，多个 DispatcherServlet 不会降低耦合性，但却增加了复杂性。

如果上下文容器的 parent 为 null, 并且当前 ServletContext 中存在根容器，则把根容器设为他的父容器。

```java
```

## ContextLoaderListener

一般我们会配置（web.xml 或 java-based）一个 org.springframework.web.context.ContextLoaderListener, 它实现了 ServletContextListener 接口, 主要用来加载根容器。

根据 Servelet 规范，这个 Listener 会在 ServletContext 创建时执行 ServletContextListener#contextInitialized. 

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

**1. context != null**  
ContextLoaderListener 有一个参数为 WebApplicationContext 的构造方法，如果创建的时候提供了这个 context 则下面不需要再创建一个 context，这个构造方法在 java config 的方式会用到，下面会说到。

```java

```

**2. context == null**  
这种情况一般是通过 web.xml 方式配置的 ContextLoaderListener。

若 context == null, 调用 ContextLoader#createWebApplicationContext 创建一个 WebApplicationContext 并将它放在 ServletContext 上下文中，以 `WebApplicationContext.ROOT_WEB_APPLICATION_CONTEXT_ATTRIBUTE` 为 key. 因此可以调用 ```servletContext.getAttribute(WebApplicationContext.ROOT_WEB_APPLICATION_CONTEXT_ATTRIBUTE)``` 拿到这个 WebApplicationContext, 更简单的方法是通过 SpringMVC 提供的工具类 ```WebApplicationContextUtils.getWebApplicationContext(servletContext)``` 

WebApplicationContext 创建完成之后（通过构造参数或者 createWebApplicationContext）接着设置 parent, 子类可以通过模版方法 loadParentContext(servletContext) 配置 web 上下文的层次结构。

调用 configureAndRefreshWebApplicationContext，初始化 WebApplicationContext, 调用他的 refresh 方法，这个方法执行后，WebApplicationContext 就创建好了，下面会详细分析。

将 WebApplicationContext（即根容器）以 ROOT_WEB_APPLICATION_CONTEXT_ATTRIBUTE 为 key 放进 ServletContext。

最后配置 currentContext。

#### createWebApplicationContext 和 configureAndRefreshWebApplicationContext

ContextLoader#createWebApplicationContext

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

确定 class 后，反射实例化一个 WebApplicationContext 的实现类，一个"裸"的根容器创建出来了。

想一想，平时为啥创建 ApplicationContext？ 

作为 Bean 容器，当然是用来管理 Bean 了。

既然用来管理 Bean，是不是应该先把 Bean 放进去？ 通过 xml？ 注解？ 或者干脆直接调用 register 方法注册？ 然后是不是应该 refresh 一下？配置一些 post-processer，设置一些参数，提前创建 Singleton？

ContextLoader#configureAndRefreshWebApplicationContext

```java
```

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