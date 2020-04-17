[Java 微服务框架选型（Dubbo 和 Spring Cloud？）](https://www.cnblogs.com/xishuai/archive/2018/04/13/dubbo-and-spring-cloud.html)
[etcd、Zookeeper和Consul一致键值数据存储的性能对比](https://cloud.tencent.com/developer/article/1491107)

## Feign
Feign 是一个 http 请求调用的轻量级框架，可以以 Java 接口注解的方式调用 Http 请求，而不用像 Java 中通过封装 HTTP 请求报文的方式直接调用。

Feign 通过处理注解，将请求模板化（或者说类型化），当实际调用的时候，传入参数，根据参数再应用到请求上，进而转化成真正的请求，这种请求相对而言比较直观。

Feign 和 dubbo 的接口调用类似，dubbo 的接口有服务端提供， Feign 由用户根据 http 请求自己做映射。

### 示例

```java


```