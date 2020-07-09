1. @Autowired 注解不能直接为静态字段注入属性，但有时候却有这个需求，可以使用 setter 注入
```java
@Component
public class AddressingUtils {

    // 不支持静态字段导入
    // @Autowired
    private static RestTemplate restTemplate;

    // 静态字段注入
    @Autowired
    public void setRestTemplate(RestTemplate restTemplate) {
        AddressingUtils.restTemplate = restTemplate;
    }
}
```
2 获取 Session, Request, ServletContext

可以通过 RequestContextHolder 获取

```java
public class RequestUtils {
    /**
     * 获取 request
     * @return
     */
    public static HttpServletRequest getRequest() {
        return ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes()).getRequest();
    }

    /**
     * 获取 Session
     * @return
     */
    public static HttpSession getSession() {
        return getRequest().getSession();
    }

    /**
     * 获取 ServletContext
     * @return
     */
    public static ServletContext getServletContext() {
        return getSession().getServletContext();
    }

    /**
     * 获取 session 属性值
     * @return
     */
    public static Account getAccout() {
        return (Account) getSession().getAttribute("account");
    }
}
```