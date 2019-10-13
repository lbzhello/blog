## SpringBoot 跨域配置

关于跨域问题，这篇比较清楚：[SpringBoot配置Cors解决跨域请求问题](https://www.cnblogs.com/yuansc/p/9076604.html)

这里仅说如何配置

### 1. 通过 @CrossOrigin

@CrossOrigin 支持类和方法，如果是类，则对类下面的所有方法有效

```java
@RestController
@RequestMapping("/user")
// 若 credentials mode is 'include',  origins 不能为 *, 且要指定 credentials 为 true
@CrossOrigin(
    origins = {"http://localhost", "http://127.0.0.1", "http://localhost:3000", "*"}, 
    allowCredentials = "true"
)
public class UserController {

    @Reference
    private UserService userService;

    @GetMapping("/{id}")
    public User get(@PathVariable("id") int id) {
        return userService.findById(id);
    }
}
```

@CrossOrigin 灵活，但是不够方便，只能配置单个类的跨域。

### 2. 通过 WebMvcConfigurer

```java
@Configuration
public class CorsConfig implements WebMvcConfigurer {
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOrigins("*")
                .allowedMethods("GET", "HEAD", "POST", "PUT", "DELETE", "OPTIONS")
                .allowCredentials(true)
                .maxAge(3600)
                .allowedHeaders("*");
    }
}
```

### 3. 通过 SpringMVC 提供的 CorsConfiguration + CorsFilter

```java
@Configuration
public class WebServletConfig {
    @Bean
    public FilterRegistrationBean corsFilter() {
        CorsConfiguration config = new CorsConfiguration();
        // 允许所有源的访问
        config.addAllowedOrigin("*");
        // 真实请求允许的方法
        config.addAllowedMethod("*");
        // 服务器允许使用的字段
        config.addAllowedHeader("*");
        // 是否允许用户发送、处理 cookie
        config.setAllowCredentials(true);
        // 预检请求的有效期，单位为秒。有效期内，不会重复发送预检请求
        config.setMaxAge(60*60*60L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        // CORS 配置对所有接口都有效
        source.registerCorsConfiguration("/**", config);

        FilterRegistrationBean bean = new FilterRegistrationBean(new CorsFilter(source));
        bean.setOrder(0);
        return bean;
    }
}
```

### 4. 自己配置一个 filter

```java
@WebFilter(urlPatterns = {"/*"})
@Component
public class CorsFilter implements Filter {
    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) throws IOException, ServletException {
        HttpServletResponse response = (HttpServletResponse) res;
        response.setHeader("Access-Control-Allow-Origin","*");
        response.setHeader("Access-Control-Allow-Credentials", "true");
        response.setHeader("Access-Control-Allow-Methods", "POST, GET, PATCH, DELETE, PUT");
        response.setHeader("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
        response.setHeader("Access-Control-Max-Age", "3600");
        chain.doFilter(req, res);
    }
}
```