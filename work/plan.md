### 2019-10-24
1. uml类图
2. 设计模式-创建型

## MySQL 优化

## gc

[JVM监控和查看](http://blog.51niux.com/?id=219)

2019-12-18
1. 工作成果
2. 工作收获
3. 不足改进
4. 规划展望

2019-12-29
Actives

2019-12-23
todo
1. spring aop 默认 jdk 动态代理，springboot （1.4 后）默认 cglib 
2. 异步？ CompeteFuture AsyncTask 
3. rxjava/reactor 各个操作符作用, 
create 中的线程不会被 onErrorContinue 捕获
from 运行在主线程，create 可以通过 subscribeOn 设置执行线程
groupby 操作统统 next发射数据源优点，避免不必要的循环

4. EventBus Scheduler cron
5. logback 使用
6. lombok
7. 单元测试

2019-12-24
1. 通过异常表示错误，而不是通过返回错误信息

2019-12-28
1. DataFlow, DataStream, DataSet
2. macro 
macro, $0 分开，e.g. a, b, $0, $1 问题，输入 a, b 返回 lambda ?  ×
全部作为 参数
def max(int, int) -> int {
    
}

3. stream
arr.map(it -> sout(it)).filter(it -> it > 0).forEach(it -> print(it))

// 避免函数嵌套调用
arr >> sout(it) >> it > 0 >> print(it)

a = getAll(qo) >> {x, y -> findById(x, y)} >> it.getName() >> sout(it)


2020-01-06
1. {name:'lbz' age:22 x, y -> x + y} x
2. {x, y -> name:'lbz' age:22 x + y} √
3. x, y -> {name: 'lbz' age:22 x + y}
4. int, int -> int {} x 返回位置复发确定
5. type
## func
let lbd = type int, int -> int {x, y ->

}

def f(int, int) -> int {
    
} 

## var
let v = Map<int, int>()
let i = int(3)


