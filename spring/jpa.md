[Spring Data JPA 基本使用](https://www.cnblogs.com/chenglc/p/11226693.html)

## @EnableJpaRepositories 
加载指定包下所有集成 Repository 接口的 bean 到容器

## @EntityScan
加载指定包下所有 @Entity 注解的 bean 到容器

**注意：**
springboot 基于自动配置，如果启动类位于根目录下，则不需要 @EnableJpaRepositories @EntityScan 注解

## 继承关系

- @Entity A 继承 @Entity B
保存 A 时各自的字段保存在各自的表中，查询 A 时会查出两张表的并集。

- @Entity A 继承 非 @Entity B
只会保存 A 的数据到 A 表

- @Entity A 继承 @MappedSuperclass B
保存 A 时会将继承自 B 的字段同时保存到 A; B 不会生成表信息

# SpringBoot 集成 jpa

## 引入依赖

```groovy
dependencies {
    compile group: 'org.springframework.boot', name: 'spring-boot-starter-data-jpa', version: '2.4.1'
    compile group: 'org.springframework.boot', name: 'spring-boot-starter-webflux', version: '2.4.1'
    compile group: 'org.postgresql', name: 'postgresql', version: '42.2.18'
}
```

## application.yml

```yml
spring:
  application:
    name: finalysis
  datasource:
    url: jdbc:postgresql://localhost:5432/stock
    username: postgres
    password: 191908577
    driver-class-name: org.postgresql.Driver
  jpa:
    show-sql: true
    hibernate:
      # 不用 jpa 删库建表
      ddl-auto: none
    database: POSTGRESQL
    properties:
      hibernate:
        format_sql: true
```

## Entity

```java
// jpa 相关注解
@Entity
@Table(name = "blog", schema = "public", catalog = "blog")
@DynamicInsert
@DynamicUpdate // 字段为 null 忽略对应的字段
@Data
public class Blog {
    @Id
    @Column(name = "id")
    private Integer id;

    @Basic
    @Column(name = "start_time")
    private Timestamp startTime;

    @Basic
    @Column(name = "end_time")
    private Timestamp endTime;
}
```

## Repository

```java
@Repository
public interface BlogRepository extends JpaRepository<Blog, Integer> {
}
```
## Service

```java
@Service
@Transactional(isolation = Isolation.DEFAULT, propagation = Propagation.REQUIRED, timeout = 3*60, rollbackFor = Exception.class)
public class BlogService {
    @Autowired
    private BlogRepository blogRepository;

    public List<Blog> queryAll() {
        blogRepository.save(blog);
        Blog one = blogRepository.getOne(1);
        blogRepository.deleteById(1);
        return blogRepository.findAll();
    }
}
```

## 启动类
```java
@ComponentScan(basePackages = "xyz.liujin.blog")
// 扫描 jpa; 不同包下需要这 2 个注解
@EntityScan(basePackages = "xyz.liujin.blog")
@EnableJpaRepositories(basePackages = "xyz.liujin.blog") // 扫描包下集成 JpaRepository 的类
@SpringBootApplication
public class BlogApplication {    
    public static void main(String[] args) {
		SpringApplication.run(BlogApplication.class, args);
	}
}
```


##
[SpringBoot中JPA的基本使用](https://blog.csdn.net/weixin_39020878/article/details/110008230)


[IDEA 自动生成 JPA 实体类](https://blog.csdn.net/mononoke111/article/details/91924002)