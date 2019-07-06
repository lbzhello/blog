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
kafka 通过 zookeeper 来存储集群的 meta 信息。
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

## Consumer 

每个Consumer都划归到一个逻辑Consumer Group中，一个partition只能被同一个Consumer Group中的一个Consumer消费，但可以被不同的Consumer Group消费。

若 topic 的 partition 数量为 p，Consumer Group 中订阅此 tiopic 的 consumer 数量为 c; 则： 

    p < c: 会有 c - p 个 consumer闲置，造成浪费
    p > c: 一个 consumer 对应多个 partition 
    p = c: 一个 consumer 对应一个 partition

应该合理分配consumer和partition的数量，避免造成资源倾斜，最好partiton数目是consumer数目的整数倍。

#### 如何将Partition分配给Consumer

生产过程中broker要分配partition，消费过程这里，也要分配partition给消费者。类似broker中选了一个controller出来，消费也要从broker中选一个coordinator，用于分配partition。

当 partition 或 consumer 数量发生变化时，比如 增加 consumer, 减少 consumer(主动或被动)，增加 partition，都会进行 rebalance。

其过程如下：

1. consumer 给 coordinator 发送 JoinGroupRequest 请求。这时其他consumer 发 heartbeat 请求过来时，coordinator 会告诉他们，要 rebalance了。其他 consumer 也发送 JoinGroupRequest 请求。
   
2. coordinator在consumer中选出一个leader，其他作为 follower，通知给各个 consumer，对于leader，还会把 follower 的 metadata 带给它。
   
3. consumer leader 根据 consumer metadata 重新分配 partition

4. consumer向coordinator发送SyncGroupRequest，其中leader的SyncGroupRequest会包含分配的情况。coordinator回包，把分配的情况告诉consumer，包括leader。

#### Consumer Fetch Message

Consumer 采用"拉模式"消费消息，这样 consumer 可以自行决定消费的行为。

Consumer 通过调用 poll(duration: int), 从服务器拉取消息。拉取消息的具体行为由下面的配置项决定：

    #consumer.properties

    #消费者最多 poll 多少个 record
    max.poll.records=500

    #消费者 poll 时 partition 返回的最大数据量
    max.partition.fetch.bytes=1048576
    
    #Consumer 最大 poll 间隔
    #超过此值服务器会认为此 consumer failed 
    #并将此 consumer 踢出对应的 consumer group 
    max.poll.interval.ms=300000

在 partition 中，每个消息都有一个 offset。新消息会被写到 partition 末尾（最新的一个 segment 文件末尾）， 每个 partition 上的消息是顺序消费的，不同的 partition 之间消息的消费顺序是不确定的。

若一个 consumer 消费多个 partition, 则各个 partition 之前消费顺序是不确定的，但在每个 partition 上是顺序消费。 

若来自不同 consumer group 的多个 consumer 消费同一个 partition，则各个 consumer 之间的消费互不影响，每个 Consumer 都会有自己的 offset。

![producer](/img/kafka/log-consumer.png)

Consumer A 和 Consumer B 属于不同的 Consumer Group。Cosumer A 读取到 offset = 9， Consumer B 读取到 offset = 11，这个值表示下次读取的位置。也就是说 Consumer A 已经读取了 offset 为 0 ~ 8 的消息，Consumer B 已经读取了 offset 为 0 ～ 10 的消息。

下次从 offset = 9 开始读取的 Consumer 并不一定还是 Consumer A 因为可能发生 rebalance

#### offset的保存

Consumer 消费 partition 时，需要保存 offset 记录当前消费位置。

offset 可以选择自动提交或调用 Consumer 的 commitSync() 或 commitAsync() 手动提交，相关配置为：
    
    #是否自动提交 offset
    enable.auto.commit=true

    #自动提交间隔。 enable.auto.commit=true 时有效
    auto.commit.interval.ms=5000

offset 保存在名叫 __consumeroffsets 的 topic 中。写消息的 key 由 groupid、topic、partition 组成，value 是 offset。

一般情况下，每个key的offset都是缓存在内存中，查询的时候不用遍历partition，如果没有缓存，第一次就会遍历 partition 建立缓存，然后查询返回。

__consumeroffsets 的 partition 数量由下面的 server 配置决定：

    offsets.topic.num.partitions=50

我们知道每个 partition 只能被同一个 Consumer Group 的一个 Consumer 消费，因此 Consumer 的 offset 存放在 ```groupId.hashCode() mode groupMetadataTopicPartitionCount```分区上，groupMetadataTopicPartitionCount 是上面配置的分区数。

## 消息系统可能遇到那些问题

kafka支持3种消息投递语义  

1. at most once：最多一次，消息可能会丢失，但不会重复  
   获取数据 -> commit offset -> 业务处理
2. at least once：最少一次，消息不会丢失，可能会重复  
   获取数据 -> 业务处理 -> commit offset。 
3. exactly once：只且一次，消息不丢失不重复，只且消费一次（0.11中实现，仅限于下游也是kafka）

#### 如何保证消息不被重复消费？（消息的幂等性）

对于更新操作，天然具有幂等性。  
对于新增操作，可以给每条消息一个唯一的id，处理前判断是否被处理过。这个id可以存储在 Redis 中，如果是写数据库可以用主键约束。

#### 如何保证消息的可靠性传输？（消息丢失的问题）

**消费端弄丢了数据**

当 server.properties/enable.auto.commit 设置为 true 的时候，kafka 会先 commit offset 在处理消息，如果这时候出现以异常，这条消息就丢失了。

因此可以关闭自动提交 offset，在处理完成后手动提交 offset，这样可以保证消息不丢失；但是如果在提交 offset 失败，可能导致重复消费的问题， 这时保证幂等性即可。

**Kafka弄丢了消息**

如果某个 broker 不小心挂了，此时若 replica 只有一个，broker 上的消息就丢失了；若 replica > 1 ,给 leader 重新选一个 follower 作为新的 leader, 如果 follower 还有些消息没有同步，这部分消息便丢失了。

可以进行如下配置，避免上面的问题：

* 给 topic 设置 replication.factor 参数：这个值必须大于 1，要求每个 partition 必须有至少 2 个副本。
* 在 Kafka 服务端设置 min.insync.replicas 参数：这个值必须大于 1，这个是要求一个 leader 至少感知到有至少一个 follower 还跟自己保持联系，没掉队，这样才能确保 leader 挂了还有一个 follower 吧。
* 在 producer 端设置 acks=all：这个是要求每条数据，必须是写入所有 replica 之后，才能认为是写成功了。
* 在 producer 端设置 retries=MAX（很大很大很大的一个值，无限次重试的意思）：这个是要求一旦写入失败，就无限重试，卡在这里了。

**Producer弄丢了消息**

在 producer 端设置 acks=all，保证所有的ISR都同步了消息才认为写入成功。

#### 如何保证消息的顺序性？

kafka 中 partition 上的消息是顺序的，可以将需要顺序消费的消息发送到同一个 partition 上，用单个 consumer 消费。

**********
上面是学习kafka时总结的，如有错误或不合理的地方，欢迎指正！

****
参考：  
[1]: [kafka学习笔记：知识点整理][1]   
[2]: [advanced-java][2]  
[3]: [Kafka的Log存储解析][3]  
[4]: [kafka生产者Producer参数设置及参数调优建议-商业环境实战系列][4]  
[5]: [震惊了！原来这才是kafka！][5]  
[6]: [kafka configuration][6]  
[7]: [kafka 2.3.0 API][7]  
[8]: [kafka consumer 配置详解和提交方式][8]

[1]: https://www.cnblogs.com/cyfonly/p/5954614.html  
[2]: https://github.com/doocs/advanced-java/blob/master/docs/high-concurrency/why-mq.md  
[3]: https://blog.csdn.net/jewes/article/details/42970799  
[4]: https://blog.csdn.net/shenshouniu/article/details/83515413
[5]: https://www.jianshu.com/p/d3e963ff8b70
[6]: http://kafka.apache.org/documentation/#configuration
[7]: http://kafka.apache.org/23/javadoc/index.html
[8]: https://blog.csdn.net/u012129558/article/details/80076327