## 问题
生产上如果某个接口访问的很慢，如何分析原因？如何定位哪里出了问题？

## 思考

接口为啥会访问很慢？是一直都慢，还是偶尔很慢？是一上线就很慢，还是上线运行一段时间后才变慢？是不是在每天的某个时点很慢？

## Sql 问题

#### 解决思路

索引，数据量，缓存，中间表

#### 如何定位问题

先通过慢查询日志，定位哪些查询比较缓慢，然后分析查询语句，看查询语句是否有问题，是否建了索引？索引是否生效了？

参考：[MySQL慢查询日志记录和分析](https://blog.csdn.net/zxd1435513775/article/details/86023501)

**通过 slow_query_log 定位慢查询语句**

MySQL 慢查询日志的相关参数：

- slow_query_log ：是否开启慢查询日志，1 表示开启，0 表示关闭。

- slow_query_log_file：新版（5.6及以上版本） MySQL 数据库慢查询日志存储路径。可以不设置该参数，系统则会默认给一个缺省的文件 host_name-slow.log。

- long_query_time ：慢查询阈值，当查询时间多于设定的阈值时，该 SQL 会被记录日志中或者数据表中。

- log_queries_not_using_indexes：未使用索引的查询也被记录到慢查询日志中（可选项）。

- log_output：日志存储方式。log_output='FILE' 表示将日志存入文件，默认值是 'FILE'。 log_output='TABLE' 表示将日志存入数据库，这样日志信息就会被写入到 mysql.slow_log 表中。MySQL 数据库支持同时两种日志存储方式，配置的时候以逗号隔开即可，如： log_output='FILE,TABLE'。日志记录到系统的专用日志表中，要比记录到文件耗费更多的系统资源，因此对于需要启用慢查询日志，又需要能够获得更高的系统性能，那么建议优先记录到文件。

查看和更改配置：

```sql
# 查看慢查询日志配置
show variables like '%slow%';

# 开启慢查询日志，默认不开启，会影响性能
set global slow_query_log = on;

# 慢查询记录时间，默认 10 秒
show variables like '%long%';

# 设置按查询阈值为 1 秒
set long_query_time = 1;

# 模拟慢查询
select sleep(5)

# 查看记录的慢查询
show global status like '%slow_queries%';
```

#### 日志分析工具 mysqldumpslow


**通过 explain 查看执行计划**
