[@ConfigurationProperties 注解使用姿势，这一篇就够了](https://blog.csdn.net/yusimiao/article/details/97622666)
## @ConfigurationProperties
注解在 Spring 管理的 bean 上，并启用 @EnableConfigurationProperties 注解。

#### Validated

## Spring Boot Configuration Processor 自动补全

## ConfigurationPropertiesBinding 自定义类型转换器

## @RunWith 
JUnit 会使用它提供的类代替 JUnit 内建的 runner

示例，SpringRunner
```java
@RunWith(SpringRunner.class)
@ContextConfiguration(classes = AppConfig.class) // 用于提供配置类
public class LocalTest {
	@Autowired
	private AppConfig appConfig;
	
	@Test
    public void localTest() throws IOException {
        appConfig.sayHello();
    }
}
```

## @RequestBody
请求数据为 json 格式时需要加

## @RequestParam
获取 url 路径中的参数