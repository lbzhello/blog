## Spring 获取 servlet 安装目录

```java
@Service
public class ServletConfig implements ServletContextAware {
    private static ServletContext servletContext;
    @Override
    public void setServletContext(ServletContext servletContext) {
        ServletConfig.servletContext = servletContext;
    }

    public String getRootPath() {
        return servletContext.getRealPath("");
    }
}
```