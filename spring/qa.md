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