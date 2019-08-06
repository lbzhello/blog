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

<span id="web-xml"></span>
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
            <load-on-startup>1</load-on-startup>
        </init-param>
    </servlet>
    <servlet-mapping>
        <servlet-name>dispatch</servlet-name>
        <servlet-pattern>/*</servlet-pattern>
    </servlet-mapping>
```

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

简单来说，只要 ClassPath 下存在 **WebApplicationContextInitializer** 的实现类，SpringMVC 会自动发现它，并且调用他的 onStartUp 方法

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

可见，它和上面 [web.xml](#web-xml) 配置方式基本一致，也配置了 ContextLoaderListener 和 DispatcherServlet 以及其持有的 application context，不过通过代码实现，逻辑更加清晰。

如果每次都需要创建 ContextLoaderListener 和 DispatcherServlet，显然不符合 KISS 原则（keep it simple and stupid）。

SpringMVC 为 WebApplicationInitializer 提供了基本的抽象实现类

![WebApplicationInitializer](/img/spring/mvc/web-application-initializer.png)

代码实现这里不再赘述，总之就是利用模版方法，调用钩子方法。子类只需提供少量的配置即可完成整个逻辑的创建。

所以，更简单的方法是继承 AbstractAnnotationConfigDispatcherServletInitializer

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

AbstractApplicationContext 有两个实现体系, 他们的区别是每次 refresh 时是否会创建一个新的 DefaultListableBeanFactory。

> DefaultListableBeanFactory 是实际存放 bean 的容器, 提供 bean 注册功能

AbstractRefreshableApplicationContext 这个 refreshable 并不是指 refresh 这个方法，而是指 refreshBeanFactory 这个方法。他会在每次 refresh 时创建一个新的 BeanFactory（DefaultListableBeanFactory）用于存放 bean，然后调用 loadBeanDefinitions 将 bean 加载到新创建的 BeanFactory。

GenericApplicationContext 内部持有一个 DefaultListableBeanFactory, 所以可以提前将 Bean 加载到 DefaultListableBeanFactory, 它也有 refreshBeanFactory 方法，但是这个方法啥也不做。

根据读取配置的方式，也可以分成 3 类，**基于 xml 的配置**, **基于 annotation 的配置**和**基于 java-based 的配置**

基于 xml 的配置使用 xml 作为配置方式, 此类的名字都含有 *Xml*, 比如从文件系统路径读取配置的 FilePathXmlApplicationContext, 从 ClassPath 读取配置的 ClassPathXmlApplicationContext, 基于 Web 的 XmlWebApplicationContext 等

基于注解的配置通过扫描指定包下面具有某个注解的类，将其注册到 bean 容器，相关注解有 @Component, @Service, @Controller, @Repository，@Named 等

java-based 的配置方式目前是大势所趋，结合注解的方式使用简单方便易懂，主要是 @Configuration 和 @Bean

上面几个类是基础类，下面是 SpringMVC 相关的 WebApplicationContext

XmlWebApplicationContext 和 AnnotationConfigWebApplicationContext 继承自 AbstractRefreshableApplicationContext， 表示它们会在 refresh 时新创建一个 DefaultListableBeanFactory， 然后 loadBeanDefinitions。 从名字可以看出它们分别从 xml 和 注解类（通常是 @Configuration 注解的配置类）中读取配置信息。

XmlEmbeddedWebApplicationContext 和 AnnotationConfigEmbeddedWebApplicationContext 与上面两个相似，从名字可以看出他们是用于 "Embedded" 方面的，即 SpringBoot 嵌入容器所使用的 WebApplicationContext 

SpringMVC 应用中几乎所有的类都交由 WebApplicationContext 管理，包括业务方面的 @Controller, @Service, @Repository 注解的类， ServletContext, 文件处理 multipartResolver, 视图解析器 ViewResolver, 处理器映射器 HandleMapping 等。

SpringMVC 通过两种方式创建 WebApplicationContext

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

#### ContextLoader#initWebApplicationContext 

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
    //当前 ServletContext 中是否已经存在 root web applicationContext
    //一个 ServletContext 中只能有一个 ServletContext
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
        // context 可以通过构造方法传入(这个 java config 方式会用到)
        if (this.context == null) {
            //若 web application 为空，创建一个, 这个一般是 web.xml 方式配置的
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
                //设置 ID, ServletContext, contextConfigLocation
                //执行 refresh 操作
                configureAndRefreshWebApplicationContext(cwac, servletContext);
            }
        }

        //将 context 设为 servlet context 参数
        //因此可以调用 servletContext.getAttribute(WebApplicationContext.ROOT_WEB_APPLICATION_CONTEXT_ATTRIBUTE) 拿到这个 WebApplicationContext
        // 更简单的方法是通过 SpringMVC 提供的工具类 WebApplicationContextUtils.getWebApplicationContext(servletContext)
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

如果 context 为 null, 则创建一个

#### ContextLoader#createWebApplicationContext

```java
protected WebApplicationContext createWebApplicationContext(ServletContext sc) {
    //决定使用哪个 WebApplicationContext 的实现类
    Class<?> contextClass = determineContextClass(sc);
    if (!ConfigurableWebApplicationContext.class.isAssignableFrom(contextClass)) {
        throw new ApplicationContextException("Custom context class [" + contextClass.getName() +
                "] is not of type [" + ConfigurableWebApplicationContext.class.getName() + "]");
    }
    //调用工具类实例化一个 WebApplicationContext
    return (ConfigurableWebApplicationContext) BeanUtils.instantiateClass(contextClass);
}

```
ContextLoader#determineContextClass 根据 ```ContextLoader.CONTEXT_CLASS_PARAM``` 确定使用哪个 WebApplicationContext 的实现类。

```java
protected Class<?> determineContextClass(ServletContext servletContext) {
    //CONTEXT_CLASS_PARAM = "contextClass", 即在 web.xml 中配置的初始化参数 contextClass
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
        //如果未配置 contextClass， 从 defaultStrategies 属性文件中获取，下面会说到
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
//属性文件中的类为 XmlWebApplicationContext。
private static final String DEFAULT_STRATEGIES_PATH = "ContextLoader.properties";


private static final Properties defaultStrategies;

//静态加载 XmlWebApplicationContext 到 defaultStrategies 中
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

确定 class 后，反射实例化一个 WebApplicationContext 的实现类，一个"裸"的根容器创建出来了。

想一想，平时为啥创建 ApplicationContext？ 

作为 Bean 容器，当然是用来管理 Bean 了。

既然用来管理 Bean，是不是应该先把 Bean 放进去？ 通过 xml？ 注解？ 或者干脆直接调用 register 方法注册？ 然后是不是应该 refresh 一下？配置一些 post-processer，设置一些参数，提前创建 Singleton？

#### ContextLoader#configureAndRefreshWebApplicationContext

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
        //初始化属性资源，占位符等，
        ((ConfigurableWebEnvironment) env).initPropertySources(sc, null);
    }

    //主要调用 ApplicationContextInitializer 接口，在 refresh 之前定制一些信息
    customizeContext(sc, wac);

    //所有的 ApplicationContext 调用 refresh 之后才可用，此方法位于
    //AbstractApplication，它统一了 ApplicationContext 初始化的基本
    //流程，子类（包括 WebApplicationContext 的实现类）通过钩子方法
    //（模版方法）定制一些自己的需求
    wac.refresh();
}
```

## DispatcherServlet

SpringMVC 将前端的所有请求都交给 DispatcherServlet 处理，他本质上是一个 Servlet，可以通过 web.xml 或者 java config 方式配置。

DispatcherServlet 类图

![dispatcher-servlet](/img/spring/mvc/dispatcher-servlet.png)

SpringMVC 将 DispatcherServlet 也当做一个 bean 来处理，所以对于一些 bean 的操作同样可以作用于 DispatcherServlet。

Servlet 容器会在启动时调用 init 方法。完成一些初始化操作，其调用流程如下：

**HttpServletBean#init -> FrameworkServlet#initServletBean -> FrameworkServlet#initWebApplicationContext** 

前面两个方法比较简单，主要是 initWebApplicationContext

#### FrameworkServlet#initWebApplicationContext

```java
/**
* Initialize and publish the WebApplicationContext for this servlet.
* <p>Delegates to {@link #createWebApplicationContext} for actual creation
* of the context. Can be overridden in subclasses.
* @return the WebApplicationContext instance
* @see #FrameworkServlet(WebApplicationContext)
* @see #setContextClass
* @see #setContextConfigLocation
*/
protected WebApplicationContext initWebApplicationContext() {
    //获取 root web application context
    WebApplicationContext rootContext =
            WebApplicationContextUtils.getWebApplicationContext(getServletContext());
    //上下文容器，当前 DispatcherServlet 持有的 WebApplicationContext
    WebApplicationContext wac = null;

    //web application 可以通过构造方法传入， java-config 方式会用到
    if (this.webApplicationContext != null) {
        wac = this.webApplicationContext;
        if (wac instanceof ConfigurableWebApplicationContext) {
            ConfigurableWebApplicationContext cwac = (ConfigurableWebApplicationContext) wac;
            if (!cwac.isActive()) {
                // The context has not yet been refreshed -> provide services such as
                // setting the parent context, setting the application context id, etc
                if (cwac.getParent() == null) {
                    // The context instance was injected without an explicit parent -> set
                    // the root application context (if any; may be null) as the parent
                    cwac.setParent(rootContext);
                }

                //配置刷新 web application context, 下面会说到
                configureAndRefreshWebApplicationContext(cwac);
            }
        }
    }
    if (wac == null) {
        // No context instance was injected at construction time -> see if one
        // has been registered in the servlet context. If one exists, it is assumed
        // that the parent context (if any) has already been set and that the
        // user has performed any initialization such as setting the context id
        wac = findWebApplicationContext();
    }
    if (wac == null) {
        // 如果通过 web.xml 方式配置，此时 wac 为空，创建一个，默认 XmlWebApplicationContext
        // 配置文件位置 contextConfigLocation 在这里加载
        // 这个方法比较简单，不再赘述
        wac = createWebApplicationContext(rootContext);
    }

    if (!this.refreshEventReceived) {
        // 初始化 SpringMVC 处理过程中面向不同功能的策略对象
        // 比如 MultipartResolver, HandlerMappings, ViewResolvers 等
        synchronized (this.onRefreshMonitor) {
            onRefresh(wac);
        }
    }

    if (this.publishContext) {
        // 将 DispatcherServlet 持有的 web application context 放进 ServletContext
        // 命名规则为 SERVLET_CONTEXT_PREFIX + dispatcherServlet 名字
        // SERVLET_CONTEXT_PREFIX = FrameWorkServlet.class.getName() + ".CONTEXT."
        String attrName = getServletContextAttributeName();
        getServletContext().setAttribute(attrName, wac);
    }

    return wac;
}
```

#### FrameworkServlet#configureAndRefreshWebApplicationContext

```java

```

#### DispatcherServlet#onRefresh

````java

````

## DispatcherServlet 处理请求

根据 Servlet 规范和 SpringMVC 实现，其处理流程大致如下

**HttpServlet#service -> FrameworkServlet#processRequest -> DispatcherServlet#doService -> DispatcherServlet#doDispatch**

#### DispatcherServlet#doDispatch

```java

```



参考：
1. [servlet监听器Listener介绍和使用][1]  
2. [UML各种图总结-精华][2]

[1]: https://blog.csdn.net/qq_15204179/article/details/82055448

[2]: https://www.cnblogs.com/jiangds/p/6596595.html