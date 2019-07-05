## 什么是消息队列？
简单来说，消息队列是存放消息的容器。客户端可以将消息发送到消息服务器，也可以从消息服务器获取消息。  

发出疑问？  

*********

1. [为什么需要消息系统？](#why-mq)
2. [kafka架构？](#kafka-cons)
3. [Producer如何发送消息？](#producer)

<span id="why-mq"></span>
## 为什么需要消息系统？  

#### 削峰  

数据库的处理能力是有限的，在峰值期，过多的请求落到后台，一旦超过系统的处理能力，可能会使系统挂掉。 

![mq-req](/img/kafka/mq-req.png)

如上图所是，系统的处理能力是2k/s，MQ处理能力是8k/s，峰值请求5k/s，MQ的处理能力远远大于数据库，在高峰期，请求可以先积压在MQ中，系统可以根据自身的处理能力以2k/s的速度消费这些请求。这样等高峰期一过，请求可能只有100/s，系统可以很快的消费掉积压在MQ中的请求。

注意，上面的请求指的是写请求，查询请求一般通过缓存解决。

#### 解耦

如下场景，S系统与A、B、C系统紧密耦合。由于需求变动，A系统修改了相关代码，S系统也需要调整A相关的代码；过几天，C系统需要删除，S紧跟着删除C相关代码；又过了几天，需要新增D系统，S系统又要添加与D相关的代码；再过几天，程序猿疯了...  

![mq-req](/img/kafka/mq-couple.png)

这样各个系统紧密耦合，不利于维护，也不利于扩展。现在引入MQ，A系统变动，A自己修改自己的代码即可；C系统删除，直接取消订阅；D系统新增，订阅相关消息即可。

![mq-req](/img/kafka/mq-decouple.png)

这样通过引入消息中间件，使各个系统都与MQ交互，从而避免它们之间的错综复杂的调用关系。

<span id="kafka-cons"></span>
## Kafka架构  

![kafka](/img/kafka/kafka-cons.png)

#### 相关概念  

```
1. broker  
kafka 集群中包含的服务器。

2. producer  
消息生产者。

3. consumer  
消息消费者

4. consumer group  
每个 consumer 都属于一个 consumer group，每条消息只能被 consumer group 中的一个 consumer 消费，但可以被多个 consumer group 消费。

5. topic  
消息的类别。每条消息都属于某个topic，不同的topic之间是相互独立的，即kafka是面向topic的。

6. partition  
每个topic分为多个partition，partition是kafka分配的单位。kafka物理上的概念，相当于一个目录，目录下的日志文件构成这个partition。

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
```

#### Topic and Logs

Message是按照topic来组织的，每个topic可以分成多个partition（对应server.properties/num.partitions）。partition是一个顺序的追加日志，属于顺序写磁盘（顺序写磁盘效率比随机写内存要高，保障 kafka 吞吐率）。其结构如下

> server.properties/num.partitions 表示文件 server.properties 中的 num.partitions 配置项，下同

![kafka topic](/img/kafka/topic.png)

partition中的每条记录（message）包含三个属性：offset, messageSize和data。其中offset表示消息偏移量；messageSize表示消息的大小；data表示消息的具体内容。

partition是以文件的形式存储在文件系统中，位置由server.properties/log.dirs指定，其命名规则为\<topic_name\>-\<partition_id\>。

比如，topic为"page_visits"的消息，分为5个partition，其目录结构为：

![partition](/img/kafka/partition.png)

> partition可能位于不同的broker上

partition是分段的，每个段是一个segment文件。segment的常用配置有：

    #server.properties

    #segment文件的大小，默认为 1G
    log.segment.bytes=1024*1024*1024
    #滚动生成新的segment文件的最大时长
    log.roll.hours=24*7
    #segment文件保留的最大时长，超时将被删除
    log.retention.hours=24*7

partition目录下包括了数据文件和索引文件，下图是某个partition的目录结构：

![log-segment](/img/kafka/log-segment.png)

index采用稀疏存储的方式，它不会为每一条message都建立索引，而是每隔一定的字节数建立一条索引，避免索引文件占用过多的空间。缺点是没有建立索引的offset不能一次定位到message的位置，需要做一次顺序扫描，但是扫描的范围很小。

索引包含两个部分（均为4个字节的数字），分别为相对offset和position。相对offset表示segment文件中的offset，position表示message在数据文件中的位置。

总结：Kafka的Message存储采用了分区(partition)，磁盘顺序读写，分段(LogSegment)和稀疏索引这几个手段来达到高效性

#### Partition and Replica

一个topic物理上分为多个partition，位于不同的broker上。如果没有 replica，一旦broker宕机，其上所有的patition将不可用。

每个partition可以有多个replica(对应server.properties/default.replication.factor)，分配到不同的broker上，其中有一个leader负责读写，处理来自producer和consumer的请求；其它作为follower从leader pull消息，保持与leader的同步。

#### 如何分配partition和replica到broker上

1. 将所有Broker（假设共n个Broker）和待分配的Partition排序
2. 将第i个Partition分配到第（i mod n）个Broker上 
3. 将第i个Partition的第j个Replica分配到第（(i + j) mode n）个Broker上

根据上面的分配规则，若replica的数量大于broker的数量，必定会有两个相同的replica分配到同一个broker上，产生冗余。因此replica的数量应该小于或等于broker的数量。

#### leader选举

kafka 在 zookeeper 中（/brokers/topics/[topic]/partitions/[partition]/state）动态维护了一个 ISR（in-sync replicas），ISR 里面的所有 replica 都"跟上"了 leader，controller将会从ISR里选一个做leader。具体流程如下：

```
1. controller 在 zookeeper 的 /brokers/ids/[brokerId] 节点注册 Watcher，当 broker 宕机时 zookeeper 会 fire watch
2. controller 从 /brokers/ids 节点读取可用broker
3. controller决定set_p，该集合包含宕机 broker 上的所有 partition
4. 对 set_p 中的每一个 partition
    4.1 从/brokers/topics/[topic]/partitions/[partition]/state 节点读取 ISR
    4.2 决定新 leader  
    4.3 将新 leader、ISR、controller_epoch 和 leader_epoch 等信息写入 state 节点
5. 通过 RPC 向相关 broker 发送 leaderAndISRRequest 命令
```

当ISR为空时，会选一个 replica（不一定是 ISR 成员）作为leader;当所有的 replica 都歇菜了，会等任一个 replica 复活，将其作为leader。

ISR(同步列表)中的follower都"跟上"了leader，"跟上"并不表示完全一致，它由 server.properties/replica.lag.time.max.ms 配置，表示leader等待follower同步消息的最大时间，如果超时，leader将follower移除ISR。

> 配置项 replica.lag.max.messages 已经移除

#### replica同步

kafka通过"拉模式"同步消息，即follower从leader批量拉取数据来同步。具体的可靠性，是由生产者(根据配置项producer.properties/acks)来决定的。

> In Kafka 0.9, request.required.acks=-1 which configration of producer is replaced by acks=all, but this old config is remained in docs.(在0.9版本，生产者配置项 request.required.acks=-1 被 acks=all 取代，但是老的配置项还保留在文档中。ps: 最新的文档2.2.x request.required.acks 已经不存在了)

|acks|description|
|--|--|
|0|producer发送消息后直接返回，不会等待服务器确认|
|1|服务器将记录写进本地log后返回，不会等待follower同步消息。leader宕机后可能丢失一部分未同步的消息|
|-1/all |服务器将记录写进本地log后，等待所有ISR内的消息同步后返回。除非leader和所有的ISR都挂掉，否则消息不会丢失|

> 在acks=-1的时候，如果ISR少于min.insync.replicas指定的数目，将会抛出NotEnoughReplicas或NotEnoughReplicasAfterAppend异常。

<span id="producer"></span>
## Prodecer如何发送消息

Producer首先将消息封装进一个ProducerRecord实例中。

![producer-record](/img/kafka/producer-record.png)

#### 消息路由
1. 发送消息时如果指定了partition，则直接使用；
2. 如果指定了key，则对key进行哈希，选出一个partition。这个hash（即分区机制）由producer.properties/partitioner.class指定的类实现，这个路由类需要实现Partitioner接口；
3. 如果都未指定，通过round-robin来选partition。

消息并不会立即发送，而是先进行序列化后，发送给Partitioner，也就是上面提到的hash函数，由Partitioner确定目标分区后，发送到一块内存缓冲区中（发送队列）。Producer的另一个工作线程（即Sender线程），则负责实时地从该缓冲区中提取出准备好的消息封装到一个批次内，统一发送到对应的broker中。其过程大致是这样的：

![producer](/img/kafka/producer.png)

> 图片来自[123archu](https://www.jianshu.com/p/d3e963ff8b70)

****
参考：  
[1]: [kafka学习笔记：知识点整理][1]   
[2]: [advanced-java][2]  
[3]: [Kafka的Log存储解析][3]  
[4]: [kafka生产者Producer参数设置及参数调优建议-商业环境实战系列][4]  
[5]: [震惊了！原来这才是kafka！][5]  
[6]: [kafka configuration][6]

[1]: https://www.cnblogs.com/cyfonly/p/5954614.html  
[2]: https://github.com/doocs/advanced-java/blob/master/docs/high-concurrency/why-mq.md  
[3]: https://blog.csdn.net/jewes/article/details/42970799  
[4]: https://blog.csdn.net/shenshouniu/article/details/83515413
[5]: https://www.jianshu.com/p/d3e963ff8b70
[6]: http://kafka.apache.org/documentation/#configuration