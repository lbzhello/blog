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

![kafka topic](/img/kafka/topic.png)

partition中的每条Message包含三个属性：offset, messageSize和data。其中offset表示消息偏移量，即消息的逻辑位置；messageSize表示data有多大；data表示message的具体内容。

partition是以文件的形式存储在文件系统中，位置由server.properties/log.dirs（表示文件server.properties中的log.dirs配置项，下同）指定，其命名规则为\<topic_name\>-\<partition_id\>。

比如，topic为page_visits的消息，分为5个partition，其目录结构为(partition可能位于不同的broker上)：

![partition](/img/kafka/partition.png)

partition是分段的，每个段叫LogSegment（大小对应server.properties/log.segment.bytes），包括了一个数据文件和一个索引文件，下图是某个partition目录下的文件：

![log-segment](/img/kafka/log-segment.png)

index采用了稀疏存储的方式，它不会为每一条message都建立索引，而是每隔一定的字节数建立一条索引，避免索引文件占用过多的空间。缺点是没有建立索引的offset不能一次定位到message的位置，需要做一次顺序扫描，但是扫描的范围很小。

索引包含两个部分（均为4个字节的数字），分别为相对offset和position。相对offset表示LogSegment的offset，position表示Message在数据文件中的位置。

总结：Kafka的Message存储采用了分区(partition)，分段(LogSegment)和稀疏索引这几个手段来达到高效性

#### 高可用性

每个partition可以有多个replica(对应server.properties/default.replication.factor)，分配到不同的broker上，其中有一个leader负责与consumer和producer交互；其它作为follower从leader pull消息，保持与leader的同步。

#### 如何分配partition和replica

1. 将所有Broker（假设共n个Broker）和待分配的Partition排序
2. 将第i个Partition分配到第（i mod n）个Broker上 （这个就是leader）
3. 将第i个Partition的第j个Replica分配到第（(i + j) mode n）个Broker上

#### leader选举



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

[1]: https://www.cnblogs.com/cyfonly/p/5954614.html  
[2]: https://github.com/doocs/advanced-java/blob/master/docs/high-concurrency/why-mq.md  
[3]: https://blog.csdn.net/jewes/article/details/42970799  
[4]: https://blog.csdn.net/shenshouniu/article/details/83515413
[5]: https://www.jianshu.com/p/d3e963ff8b70