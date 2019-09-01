## 基本数据类型

#### 整数

|类型|TINYINT|SMALLINT|MEDIUMINT|INT|BIGINT
|:--:|:--:|:--:|:--:|:--:|:--:|
|BIT|8|16|24|32|64|

> UNSIGNED 属性可以是大小提高一倍

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

如果可能给，尽量避免使用字符串作为表示列，因为它们很耗费空间，并且通常比整数慢。（MyISAM 默认对字符串使用压缩索引，会导致查询很慢）

随机字符串作为索引时，插入操作会随机的写到索引的不同位置，从而导致页分裂、磁盘随机访问，以及对于聚簇存储引擎产生聚簇索引碎片，使得插入变慢；也会是 SELECT 语句变慢，因为逻辑上相邻的行分布在磁盘和内存的不同位置；也不利于缓存，因为热点数据分散了

#### 特殊类型

IPV4 可以用整数存储，MySQL 提供了 INET_ATON() 和 INET_NTOA() 用于 IP 地址和整数之间的转换


