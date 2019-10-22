## 基本数据类型

#### 整数

|类型|TINYINT|SMALLINT|MEDIUMINT|INT|BIGINT
|:--:|:--:|:--:|:--:|:--:|:--:|
|BIT|8|16|24|32|64|

> UNSIGNED 属性可以使大小提高一倍

#### 实数

DECIMAL(m, n) 用于存储精确实数, m 表示总长度， n 表示小数部分。DECIMAL 只是一种存储格式，

浮点类型 FLOAT 使用 4 个字节存储，DOUBLE 使用 8 字节存储。MySQL 使用 DOUBLE 作为内部浮点计算的类型。

#### 字符串

VARCHAR 可变长字符串（如果使用 ROW_FORMAT=FIXED 创建，则是定长的）。VARCHAR 需要使用 1 或 2 个额外字节记录字符串的长度，如果列的长度小于 255 字节，则使用 1 个字节，否则使用 2 个字节。因此一个 VARCHAR(10) 的列需要 11 个字节的存储空间，VARCHAR(1000) 需要 1002 个字节的存储空间。

由于 VARCHAR 是变长的，所以 UPDATE 的时可能使行占用更多的空间，若页内没有更多的空间可以存储， MyISAM 会将行拆成不同的片段存储， InnoDB 会分裂页来使行可以放进页内。

CHAR 是定长的，MySQL 会删除所有的末尾空格，并且用空格填充。

VARCHAR(200) 和 VARCHAR(10) 存储 'hello' 的空间开销是一样的，但在使用临时表排序是会分配更多的空间，表现也更糟糕。

BINARY 和 VARBINARY 用于存储二进制字符串，即存储的是字节码而不是字符。MySQL 用 '\0' 填充 BINARY, 检索时不会去掉填充值。

#### 大数据量的字符串

BLOB 采用二进制存储，没有排序规则和字符集

|类型|TINYBLOB|SMALLBLOB/BLOB|MEDIUMBLOB|LONGBLOB|
|:--:|:--:|:--:|:--:|:--:|:--:|
|最大|255|65K|16M|4G|

TEXT 采用字符存储， 有排序规则和字符集

|类型|TINYTEXT|SMALLTEXT/TEXT|MEDIUMTEXT|LONGTEXT|
|:--:|:--:|:--:|:--:|:--:|:--:|
|字节|255|65K|16M|4G|

BLOG 和 TEXT 只对每个列前 max_sort_length 字节排序。如果只需要排序前面一小部分字符，可以减小 max_sort_length 的配置，或者使用 SUSTRING(column, length)。

#### ENUM

ENUM 使用整数存储， ENUM 使用内部的整数而不是定义的字符串进行排序。

> 可以是用 FIELD() 函数指定排序的顺序，这样 MySQL 无法使用索引消除排序。
> 如： select e from enum_test order by FIELD(e, 'apple', 'dog', 'fish')

#### 日期和时间

DATETIME 范围 1001-9999 年，精度为秒。他把日期和时间封装到格式为 YYYYMMDDHHMMSS 的整数中，与失去无关。使用 8 个字节的存储空间。

TIMESTAMP 类型保存了从 1970-01-01(格林尼治标准时间)以来的秒数，和 UNIX 时间戳相同，依赖于不同的时区，使用 4 个字节的存储空间，只能表示 1970-2038 年。

> MySQL 提供了 FROM_UNIXTIME() 把 UNIX 时间戳转化为日期；UNIX_TIMESTAMP() 函数把日期转化为 UNIX 时间戳。

> MySQL 默认会更新第一个 TIMESTAMP 列的值

#### 位数据类型

#### BIT

BIT 最大长度 64 位。BIT 检索式会以字符串显示，计算时用它表示的数字。例如对于 '00111001'(二进制值为 57)，检索时得到的是字符码为 57 的字符串 "9", 在上下文场景中是数字 57

#### SET

MySQL 使用一系列打包的位集合表示 SET, 缺点是改变列的定义的代价比较高。

#### 主键

足够的前提下尽量选择较小的数据类型，能用 TINYINT 就不要用 INT

整数通常是标识列最好的选择，因为他们很快并且可以使用 AUTO_INCREMENT; 

如果可能，尽量避免使用字符串作为表示列，因为它们很耗费空间，并且通常比整数慢。（MyISAM 默认对字符串使用压缩索引，会导致查询更慢）

随机字符串作为索引时，插入操作会随机的写到索引的不同位置，从而导致页分裂、磁盘随机访问，以及对于聚簇存储引擎产生聚簇索引碎片，使得插入变慢；也会是 SELECT 语句变慢，因为逻辑上相邻的行分布在磁盘和内存的不同位置；也不利于缓存，因为热点数据分散了

#### 特殊类型

IPV4 可以用整数存储，MySQL 提供了 INET_ATON() 和 INET_NTOA() 用于 IP 地址和整数之间的转换


## 架构



## 存储引擎

#### InnoDB

InnoDB 通过 MVCC 支持高并发，并且实现了四个默认的隔离级别，默认隔离级别是 REPEATABLE READ(可重复读)，并且通过间隙锁(next-key locking)策略防止幻读的出现。

InnoDB 的主键索引是聚簇索引，聚簇索引对逐渐查询有很高的性能，不过他的二级索引（secondary index, 非主键索引）中必须包含主键列。如果主键列很大，其他所有索引都会很大，因此主键应尽可能的小。InnoDB 的存储格式是平台独立的。**在大多数情况下，你应该选择InnoDB 引擎**。

#### MyISAM

MyISAM 提供了全文索引，压缩，空间函数等特性，但 MyISAM 不支持事务和行级锁，而且崩溃后无法安全恢复。对于只读的数据，或者表比较小，并且可以容忍修复（repair）操作，可以使用 MyISAM。

## 选择合适的存储引擎

大多数情况下，InnoDB 都是正确的选择，它也是 MySQL 的默认存储引擎（5.5 版本后）。除非需要用到某些 InnoDB 不具备的特性，并且没有其他方法可以替代，否则都应该优先选择 InnoDB 引擎。

### 如何选择存储引擎

#### 事务

#### 备份

#### 崩溃恢复

#### 特有的特性
只有 MyISAM 支持地理空间搜索

## 索引

MySQL 中索引是在存储引擎层而不是在服务层实现的。

B-Tree 索引能够加快访问数据的速度，因为存储引擎不再需要进行全表扫描获取需要的数据。

存储引擎以不同的方式使用 B-Tree 索引，性能也各有不同，各有优劣。MyISAM 使用前缀压缩使得索引更小；InnoDB 按照原数据格式进行存储。MyISAM 索引通过数据的物理位置引用被索引的行；InnoDB 根据主键引用被索引的行。

关于索引可参考 [B+Tree 索引](btree.md)

B+Tree 索引适用于全值键，键值范围或键前缀查找。其中键前缀查找只适用于根据最左前缀的查找。索引对如下的查询类型有效。

假设有如下表：

```sql
create table people (
    people_id int unsigned not null auto_increment comment '主键',
    pname varhcar(64) not null default '' comment '姓名',
    age int unsigned not null default now() comment '年龄'
) engine=InnoDB default charset=utf8
comment='用户表';

alter table people add index ix_pname_age (pname, age);
```

**全值匹配**  
全值匹配指的是和索引中的所有列进行匹配。如上面的索引可以查找 pname = 'tom' 并且 age = 22 的人。

**匹配最左前缀**  
只使用索引的第一列。前面的索引可以查找所有 pname = 'tom' 的人。

**匹配列前缀**  
只能匹配某一列的开头部分。前面的索引可以查找所有 pname like 'T%' 的人。

**匹配范围值**  
匹配第一列某个范围值。比如 pname 在 aaa 和 ddd 之间的人。

**精确匹配前面列并范围匹配后面的列**  
匹配 pname = 'Tom' 并且 age 在 20-25 之间的人。

**覆盖索引**
返回的列中的值都在索引中，即只访问索引的查询。比如  
```sql
select pname, age from people where pname = 'Tom' and age > 18;
```
由于 pname 和 age 的值都在索引中，所以无需访问数据行。

**索引排序**  
因为索引树中的节点都是有序的，所以索引可以用于查询中的 order by 操作。

### 索引失效

- 不符合最左前缀规则。比如 where pname like '%om' 无法使用索引。

- 不能跳过索引中的列。比如 wherer age = 22 无法使用索引。

- 如果某个列为范围查询，则其后面的列无法使用索引，比如 where pname like 'Tom%' and age = 22 此时 age 无法使用索引。

- or 语句前后没有同时使用索引。

- 数据类型出现隐式转化。比如 varchar 不加单引号的话可能会自动转换为int型，使索引无效，产生全表扫描。

- 在索引列上使用 IS NULL 或 IS NOT NULL操作。索引是不索引空值的，所以这样的操作不能使用索引，可以用其他的办法处理，例如：数字类型，判断大于0，字符串类型设置一个默认值，判断是否等于默认值即可。

- 在索引字段上使用not，<>，!=。不等于操作符是永远不会用到索引的，因此对它的处理只会产生全表扫描。 优化方法： key<>0 改为 key>0 or key<0。

- 对索引字段进行计算操作。

- 在索引字段上使用函数。（8.0 可以使用）;

- 当全表扫描速度比索引速度快时，mysql会使用全表扫描，此时索引失效。（数据少，区分度少）。

### explain
explain 可以查看 SQL 语句的执行情况, 判断有没有使用索引。

用法可参考 [MySQL 性能优化神器 Explain 使用分析](https://segmentfault.com/a/1190000008131735)

### 优化

#### 哈希索引

InnoDB 支持自适应哈希索引（adaptive hash index）。当某些索引值被使用得非常频繁时，它会在内存基于 B+Tree 之上再创建一个哈希索引。这是一个完全自动的、内部的行为，用户无法控制或配置，不过如果有必要，可以关闭这个功能。

创建自定义哈希索引。如下查询

```sql
select id from some_url where url = 'https://www.mysql.com';
```
当需要存储大量的 url, 并且需要根据 url 进行查找，如果使用 B-Tree 存储 url，存储的内容就会很大。

可以删除 url 列上的索引，新增一个索引列 url_crc, 使用 CRC32 做哈希。

```sql
select id from some_url where url = 'https://www.mysql.com' and url_crc = crc32('https://www.mysql.com');
```

注意不要是用 sha1() 或 md5() 作为哈希值，因为它们计算出来的值是非常长的字符串，会浪费大量的空间，比较时也会更慢。

如果数据量非常大，可能产生大量的哈希冲突，可以自己实现一个 64 位函数。

