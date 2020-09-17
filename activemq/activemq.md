# ActiveMQ


## 启动

### 进入 bin 目录
```sh
# 启动
activemq start

# 关闭
activemq stop

# 查看状态
activemq status
```

## web 管理界面
默认管理后台端口号： 8161
用户名：admin
密码：  admin 

本地访问 http://localhost:8161


## MQ 服务

默认服务监听端口号：61616 tcp 协议

## 常见问题

### Topic 无法接收到消息
【原因】： Springboot 整合 ActiveMQ 默认只能监听 Queue 队列的消息进行处理，即配置项 spring.jms.pub-sub-domain=false。

【解决】：
**方案一：** 将上面的配置项改为 true， 即 topic 模式。（这样 queue 就无法接收到消息了）
**方案二：** 发送目的地直接写消息名。如下所示：
```java
@GetMapping("/send/{message}")
public void send(@PathVariable("message") String message) {
    // 发送到 topic 
    // 默认无法发送到 topic, 需要将 spring.jms.pub-sub-domain=false 改为 true
    producer.send(new ActiveMQTopic("demo-topic"), message);

    // 发送到 queue
    producer.send(new ActiveMQQueue("demo-queue"), message);

    // 直接使用名字可以发送到 topic
    jmsTemplate.convertAndSend("demo-topic", "jms send");

}
```

**方案三：** 配置不同的 ConnectionFactory, 一个使用 topic 模式，一个使用 queue 模式。

ConnectionFactory 配置
```java
@Bean
public ConnectionFactory getActiveMqConnection(){
    return new ActiveMQConnectionFactory(host);
}

@Bean(name="queueListenerContainerFactory")
public JmsListenerContainerFactory queueListenerContailerFactory(ConnectionFactory connectionFactory){
    DefaultJmsListenerContainerFactory factory = new DefaultJmsListenerContainerFactory();
    factory.setConnectionFactory(connectionFactory);
    factory.setPubSubDomain(false);
    return factory;
}
@Bean(name="topicListenerContainerFactory")
public JmsListenerContainerFactory topicListenerContainerFactory(ConnectionFactory connectionFactory){
    DefaultJmsListenerContainerFactory factory = new DefaultJmsListenerContainerFactory();
    factory.setConnectionFactory(connectionFactory);
    factory.setPubSubDomain(true);
    return factory;
}
```

@JmsListener 添加 connectionFactory 属性
```java
@Component
public class ActiveMQConsumer {
    //接收queue消息
   @JmsListener(destination = "queue_test",containerFactory =     
                   "queueListenerContainerFactory")
    public void handler(String message){
        System.out.println(message);
    }
    //接收topic消息
    @JmsListener(destination = "topic_test",containerFactory = 
                "topicListenerContainerFactory")
    public void handlerTopic(String msessage){
        System.out.println(msessage);
    }
}
```

**参考：** [解决Springboot整合ActiveMQ发送和接收topic消息的问题](https://www.cnblogs.com/sjq0928/p/11371620.html)