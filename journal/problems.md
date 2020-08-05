#### 缓存的一致性问题

机构修改不生效但是数据库里面是有效的

#### 接口查询缓慢的问题

1. 首页不同接口异步加载

2. 预警人员 userService 查询缓慢 jpa 100k+

sql 语句很快 -> for 循环很快 -> 数据量过多，jpa 转换很慢
userManager 比 service 慢很多，dtf 转换

#### rest 跨域问题

#### 不同数据库事物问题，join 问题

#### 按照不同字段排序问题
首页消息提示按照时间排序

### 缓存
rpc -> local db -> cache 可以改为 rpc + cache

缓存不需要全量同步，需要时在缓存

## redis 缓存不生效

spring cache 原理 CacheManager + Cache

可能项目其他地方配置了 CacheManager ?

- 缓存失效
- cacheManager.getCache(SERVICE_DISCOVERY_CACHE).evict(componentId + "." + segmentId);