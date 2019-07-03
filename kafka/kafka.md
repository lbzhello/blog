## 什么是消息队列？
简单来说，消息队列是存放消息的容器。客户端可以将消息发送到消息服务器，也可以从消息服务器获取消息。  

发出疑问？  

*********

1. [为什么需要消息系统？](#why-mq)
2. [kafka架构？](#kafka-struct)

<span id="why-mq"></span>
## 为什么需要消息系统？  

#### 削峰  

数据库的处理能力是有限的，在峰值期，过多的请求落到后台，一旦超过系统的处理能力，可能会使系统挂掉。 

![mq-req](/img/kafka/mq-req.png)

如上图所是，MQ处理能力是8k/s，而S系统的处理能力是2k/s，峰值请求5k/s，MQ的处理能力远远大于数据库，在高峰期，请求可以先积压在MQ中，系统可以根据自身的处理能力以2k/s的速度消费这些请求。这样等高峰期一过，请求可能只有100/s，S系统可以很快的消费掉积压在MQ中的请求。

注意，上面的请求指的是写请求，查询请求一般通过缓存解决。

#### 解耦

如下场景，S系统与ABC系统紧密耦合。由于需求变动，A系统修改了相关代码，S系统也需要调整与A相关的代码；过几天，C系统需要删除，S紧跟着删除C相关代码；又过了几天，需要新增D系统，S系统又要添加与D相关的代码；再过几天，程序猿疯了...  

![mq-req](/img/kafka/mq-couple.png)

这样各个系统紧密耦合，不利于维护，也不利于扩展。现在引入MQ，A系统变动，A自己修改自己的代码即可；C系统删除，直接取消订阅；D系统新增，订阅相关消息即可。

![mq-req](/img/kafka/mq-decouple.png)

这样通过引入消息中间件，使各个系统都与MQ交互，从而避免它们之间的错综复杂的调用关系。

<span id="kafka-struct"></span>
## Kafka架构  

![kafka](/img/kafka/kafka.png)

#### 名词解释：  

1. broker  
kafka 集群中包含的服务器。

2. producer  
消息生产者。

3. consumer  
消息消费者

4. consumer group  
每个 consumer 都属于一个 consumer group，每条消息只能被 consumer group 中的一个 consumer 消费，但可以被多个 consumer group 消费。

5. topic  
消息的类别。每条消息都属于某个topic，producer将消息发送到指定topic，consumer订阅相应topic的消息

6. partition  
kafka分配的单位，物理上的概念,相当于一个目录，目录下的日志文件属于这个partition。每个topic分为多个partition；producer可以将消息发送到topic的指定partition。

7. replica  
partition的副本，保障 partition 的高可用。

8. leader  
replica 中的一个角色， producer 和 consumer 只跟 leader 交互。

9. follower  
replica 中的一个角色，从 leader 中复制数据。

10. controller  
kafka 集群中的其中一个服务器，用来进行 leader election 以及 各种 failover。

12. zookeeper  
kafka 通过 zookeeper 来存储集群的 meta 信息。比如服务器中leader信息，topic，partition在broker中的位置，consumer中消费消息的offset等。



****
参考：  
[1]: https://github.com/doocs/advanced-java/blob/master/docs/high-concurrency/why-mq.md
