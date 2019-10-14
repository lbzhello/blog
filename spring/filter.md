## SpringBoot 配置 filter

### 1. 注解方式： @WebFilter + @Component

通过 @WebFilter 注解声明一个 filter，组件必须实现 Filter 接口。

```java
// 也可以是 @Configuration
@Component
@WebFilter(urlPatterns = {"/*"})
public class CorsWebFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        System.out.println("CorsWebFilter before");
        chain.doFilter(request, response);
        System.out.println("CorsWebFilter after");
    }

    @Override
    public void destroy() {}
}
```
如果 filter 没有加 @Component 注解, 则需要通过 @ServletComponentScan 配置告诉 Spring filter 的位置。

比如：

```java
@Configuration
// @ServletComponentScan 注解仅支持嵌入式容器
@ServletComponentScan(basePackages = {"xyz.lius.web.filter"})
public class WebServletConfig {
    
}
```

> 同样可以通过 @WebServlet, @WebListener 配置 servlet 和 listener. 

### 2. java-config 配置方式： FilterRegistrationBean

配置一个 FilterRegistrationBean 类型的 bean，通过这个 bean 注册 filter. (listener 和 servlet 与此类似)

```java
@Configuration
public class WebServletConfig {
    @Bean
    public FilterRegistrationBean myFilter() {
        FilterRegistrationBean<Filter> registrationBean = new FilterRegistrationBean<>();
        // MyFilter 是任意 Filter
        registrationBean.setFilter(new MyFilter());
        // 拦截所有路径
        registrationBean.addUrlPatterns("/*");
        return registrationBean;
    }
```

### 3. 传统的 web.xml 方式