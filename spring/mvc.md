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
    <context-param>
        <!--root web application context, 通过 ContextLoaderListener 加载-->
        <param-name>contextConfigLocation</param-name>
        <param-value>classpath:applicationContext.xml</param-value>
    </context-param>

    <context-param>
        <!--可以不配置，默认为 XmlWebApplicationContext-->
        <param-name>contextClass</param-name>
        <!--WebApplicationContext 实现类-->
        <param-value>org.springframework.web.context.support.XmlWebApplicationContext</param-value>
    <context-param>

    <listener>
        <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
    </listener>

    <servlet>
        <servlet-name>dispatcher</servlet>
        <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
        <init-param>
            <!--DispatchServlet 持有的 WebApplicationContext-->
            <param-name>contextConfigLocation</param-name>
            <param-value>/WEB-INF/applicationContext.xml</param-value>
        </init-param>
    </servlet>
    <servlet-mapping>
        <servlet-name>dispatch</servlet-name>
        <servlet-pattern>/*</servlet-pattern>
    </servlet-mapping>
```

其启动流程大致是这样的,下面会详细分析

![spring-mvc-xml]()

#### 通过 ServletContainerInitializer
这个是 Servlet 3.0 的规范，新的 code-based 的配置方式。简单来说就是容器会去加载文件JAR包下 META-INF/services/javax.servlet.ServletContainerInitalizer 文件中声明的 ServletContainerInitalizer（SCI） 实现类，并调用他的 onStartup 方法，可以通过 @HandlesTypes 注解将特定的 class 添加到 SCI。

在 spring-web 模块下有个文件 META-INF/services/javax.servlet.ServletContainerInitalizer

![sci]()

SpringServletContainerInitalizer

```java
@HandlesTypes(WebApplicationInitializer.class)
public class SpringServletContainerInitializer implements ServletContainerInitializer {

	@Override
	public void onStartup(@Nullable Set<Class<?>> webAppInitializerClasses, ServletContext servletContext)
			throws ServletException {

		List<WebApplicationInitializer> initializers = new LinkedList<>();

		if (webAppInitializerClasses != null) {
			for (Class<?> waiClass : webAppInitializerClasses) {
				// Be defensive: Some servlet containers provide us with invalid classes,
				// no matter what @HandlesTypes says...
				if (!waiClass.isInterface() && !Modifier.isAbstract(waiClass.getModifiers()) &&
						WebApplicationInitializer.class.isAssignableFrom(waiClass)) {
					try {
						initializers.add((WebApplicationInitializer)
								ReflectionUtils.accessibleConstructor(waiClass).newInstance());
					}
					catch (Throwable ex) {
						throw new ServletException("Failed to instantiate WebApplicationInitializer class", ex);
					}
				}
			}
		}

		if (initializers.isEmpty()) {
			servletContext.log("No Spring WebApplicationInitializer types detected on classpath");
			return;
		}

		servletContext.log(initializers.size() + " Spring WebApplicationInitializers detected on classpath");
		AnnotationAwareOrderComparator.sort(initializers);
		for (WebApplicationInitializer initializer : initializers) {
			initializer.onStartup(servletContext);
		}
	}

}


```

它会探测并加载 ClassPath 下 **WebApplicationContextInitializer** 的实现类，调用它的 onStartUp 方法。

下面是一个 SpringMVC 的 java-based 配置方式：

```java
public class MyWebAppInitializer implements WebApplicationInitializer {
 
    @Override
    public void onStartup(ServletContext container) {
        // Create the 'root' Spring application context
        AnnotationConfigWebApplicationContext rootContext = new AnnotationConfigWebApplicationContext();
        rootContext.register(AppConfig.class);

        // Manage the lifecycle of the root application context
        container.addListener(new ContextLoaderListener(rootContext));

        // Create the dispatcher servlet's Spring application context
        AnnotationConfigWebApplicationContext dispatcherContext = new AnnotationConfigWebApplicationContext();
        dispatcherContext.register(DispatcherConfig.class);

        // Register and map the dispatcher servlet
        ServletRegistration.Dynamic dispatcher = container.addServlet("dispatcher", new DispatcherServlet(dispatcherContext));
        dispatcher.setLoadOnStartup(1);
        dispatcher.addMapping("/");
    }
}
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

## WebApplicationContext

SpringMVC 用 Spring 化的方式来管理 web 请求中的各种对象。

什么是 Spring 化？ IOC 和 AOP, 这不是本文的重点，具体自行查阅。

SpringMVC 会通过 WebApplicationContext 来管理服务器请求中涉及到的各种对象和他们之间的依赖关系。我们不需要花费大量的精力去理清各种对象之间的复杂关系，而是以离散的形式专注于单独的功能点。

WebApplicationContext 继承自 ApplicationContext, 它定义了一些新的作用域，提供了 getServletContext 接口。

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

WebApplicationContext 类图

![web](/img/spring/ioc/application-context.png)

ApplicationContext 有一个抽象实现类 AbstractApplicationContext, 模板方法的设计模式。它有一个 refresh 方法，它定义了**加载或初始化** bean 配置的基本流程。后面的实现类提供了不同的读取配置的方式，可以是 xml, file, annotation, web 等，并且可以通过模板方法定制自己的需求。

AbstractApplicationContext 有两个实现体系。

AbstractRefreshableApplicationContext 

XmlWebApplicationContext 从 xml 文档中获取配置信息。配置文件的位置由 contextConfigLocation 参数决定。

```xml
    <context-param>
        <!--root web application context, 通过 ContextLoaderListener 加载-->
        <param-name>contextConfigLocation</param-name>
        <param-value>classpath:applicationContext.xml</param-value>
    </context-param>

    <context-param>
        <!--可以不配置，默认为 XmlWebApplicationContext-->
        <param-name>contextClass</param-name>
        <!--WebApplicationContext 实现类-->
        <param-value>org.springframework.web.context.support.XmlWebApplicationContext</param-value>
    <context-param>

    <listener>
        <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
    </listener>

    <servlet>
        <servlet-name>dispatcher</servlet>
        <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
        <init-param>
            <!--DispatchServlet 持有的 WebApplicationContext-->
            <param-name>contextConfigLocation</param-name>
            <param-value>/WEB-INF/applicationContext.xml</param-value>
        </init-param>
    </servlet>
    <servlet-mapping>
        <servlet-name>dispatch</servlet-name>
        <servlet-pattern>/*</servlet-pattern>
    </servlet-mapping>
```

AnnotationConfigWebApplicationContext 和 AnnotationConfigApplicationContext 类似，以 code-based 方式加载 Bean 配置信息，但额外提供了 web 相关的功能。通常会提供一个 @Configuration 注解的配置类作为配置信息。

```java
public class MyWebAppInitializer implements WebApplicationInitializer {
 
    @Override
    public void onStartup(ServletContext container) {
        // Create the 'root' Spring application context
        AnnotationConfigWebApplicationContext rootContext = new AnnotationConfigWebApplicationContext();
        rootContext.register(AppConfig.class);

        // Manage the lifecycle of the root application context
        container.addListener(new ContextLoaderListener(rootContext));

        // Create the dispatcher servlet's Spring application context
        AnnotationConfigWebApplicationContext dispatcherContext = new AnnotationConfigWebApplicationContext();
        dispatcherContext.register(DispatcherConfig.class);

        // Register and map the dispatcher servlet
        ServletRegistration.Dynamic dispatcher = container.addServlet("dispatcher", new DispatcherServlet(dispatcherContext));
        dispatcher.setLoadOnStartup(1);
        dispatcher.addMapping("/");
    }
}
```

SpringMVC 应用中几乎所有的类都交由 WebApplicationContext 管理，包括业务方面的 @Controller, @Service, @Repository 注解的类， ServletContext, 文件处理 multipartResolver, 视图解析器 ViewResolver, 处理器映射器 HandleMapping 等。

SpringMVC 可以通过两种方式创建 WebApplicationContext

一种是通过 ContextLoaderListener, 它创建的 WebApplicationContext 称为 root application context，或者说根容器。一个 ServletContext 中只能有一个根容器，而一个 web application 中只能有一个 ServletContext，因此一个 web 应用程序中只能有一个根容器，**根容器不是必要的**。

另一种是通过 DispatcherServlet, 它创建的 WebApplicationContext，称为上下文容器，上下文容器只在 DispatcherServlet 范围内有效。DispatcherServlet 本质上是一个 Servlet，因此可以有多个 DispatcherServlet，也就可以有多个上下文容器。**但是一般情况下没必要这样做**，多个 DispatcherServlet 不会降低耦合性，但却增加了复杂性。

如果上下文容器的 parent 为 null, 并且当前 ServletContext 中存在根容器，则把根容器设为他的父容器。

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
public ContextLoaderListener(WebApplicationContext context) {
    super(context);
}
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
private static final String DEFAULT_STRATEGIES_PATH = "ContextLoader.properties";


private static final Properties defaultStrategies;

static {
    // Load default strategy implementations from properties file.
    // This is currently strictly internal and not meant to be customized
    // by application developers.
    try {
        ClassPathResource resource = new ClassPathResource(DEFAULT_STRATEGIES_PATH, ContextLoader.class);
        defaultStrategies = PropertiesLoaderUtils.loadProperties(resource);
    }
    catch (IOException ex) {
        throw new IllegalStateException("Could not load 'ContextLoader.properties': " + ex.getMessage());
    }
}
```

ContextLoader.properties 文件中的类就是 XmlWebApplicationContext。感觉这部分不太重要，了解就行。

确定 class 后，反射实例化一个 WebApplicationContext 的实现类，一个"裸"的根容器创建出来了。

想一想，平时为啥创建 ApplicationContext？ 

作为 Bean 容器，当然是用来管理 Bean 了。

既然用来管理 Bean，是不是应该先把 Bean 放进去？ 通过 xml？ 注解？ 或者干脆直接调用 register 方法注册？ 然后是不是应该 refresh 一下？配置一些 post-processer，设置一些参数，提前创建 Singleton？

ContextLoader#configureAndRefreshWebApplicationContext

```java
protected void configureAndRefreshWebApplicationContext(ConfigurableWebApplicationContext wac, ServletContext sc) {
    if (ObjectUtils.identityToString(wac).equals(wac.getId())) {
        // The application context id is still set to its original default value
        // -> assign a more useful id based on available information
        String idParam = sc.getInitParameter(CONTEXT_ID_PARAM);
        if (idParam != null) {
            wac.setId(idParam);
        }
        else {
            // Generate default id...
            wac.setId(ConfigurableWebApplicationContext.APPLICATION_CONTEXT_ID_PREFIX +
                    ObjectUtils.getDisplayString(sc.getContextPath()));
        }
    }

    //WebApplication 会持有当前 ServletContext
    wac.setServletContext(sc);
    //CONFIG_LOCATION_PARAM = "contextConfigLocation", web.xml 里面配置参数 
    //root web application context 的 Bean 配置文件
    String configLocationParam = sc.getInitParameter(CONFIG_LOCATION_PARAM);
    if (configLocationParam != null) {
        wac.setConfigLocation(configLocationParam);
    }

    // The wac environment's #initPropertySources will be called in any case when the context
    // is refreshed; do it eagerly here to ensure servlet property sources are in place for
    // use in any post-processing or initialization that occurs below prior to #refresh
    ConfigurableEnvironment env = wac.getEnvironment();
    if (env instanceof ConfigurableWebEnvironment) {
        //替换一些配置参数
        ((ConfigurableWebEnvironment) env).initPropertySources(sc, null);
    }

    //主要调用 ApplicationContextInitializer 接口，在 refresh 之前定制一些信息
    customizeContext(sc, wac);

    //这个比较常见了，注册 BeanDefinition，添加一些 post-processer,
    //对于 WebApplicationContext, 还会配置一些 Web 相关的东东
    //比如一些 Web 特有的 Scope 处理器，将 ServletContext 添加到
    //WebApplicationContext 等
    wac.refresh();
}
```

对于 WebApplicationContext 他有两个最常用的实现类， 基于 java 配置的 


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