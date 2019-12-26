## YAML (YAML Ain't Markup Language/Yet Another Markup Language)
Yaml 是一个可读性高，易用的数据序列化格式.

### 语言特点
- 大小写敏感
- 使用空格缩进表示层级关系，摒弃使用 tab 键，这主要是考虑到不同平台上文本展现时需要对齐
- 缩进的空格数目不重要，只要相同层级的元素左侧对齐即可
- 使用 # 开头作为注释行, ~ 表示 null
- 使用 连接符(-)开头来描述数组元素

### 语法
Yaml 是非常简单的， 它所定义的元素只有三个：
- 对象：就是键值对的集合，对应于Java 中的 HashMap
- 数组：指一组按序排列的值，用 - 表示，对应于Java 中的 List
- 单值：单个的、不可再分的值，比如 3，"Jackson"

#### 对象

```yaml

# 简单键值对
key1: value1
key2: value2

# 层级结构
people:
  name: maria
  age: 22

# 可以使用 {}
people: {
    name: maria,
    age: 22
}

# 复杂的对象: '?' 加一个空格代表一个复杂的 key, ':' 加一个空格代表一个 value
? - key1
  - key2
: - value1
  - value2
```

#### 数组

```yaml
# '-' 表示数组
american:
  - Boston Red Sox
  - Detroit Tigers
  - New York Yankees
national:
  - New York Mets
  - Chicago Cubs
  - Atlanta Braves

# 或者

american:
  - 
    Boston Red Sox
    Detroit Tigers
    New York Yankees
national:
  - 
    New York Mets
    Chicago Cubs
    Atlanta Braves

# [] 格式
american: [Boston Red Sox, Detroit Tigers, New York Yankees]
national: [New York Mets, Chicago Cubs, Atlanta Braves]
```

### 常量

```yaml
boolean: 
    - TRUE  #true,True都可以
    - FALSE  #false，False都可以
float:
    - 3.14
    - 6.8523015e+5  #可以使用科学计数法
int:
    - 123
    - 0b1010_0111_0100_1010_1110    #二进制表示
null:
    nodeName: 'node'
    parent: ~  #使用~表示null
string:
    - 哈哈
    - 'Hello world'  #可以使用双引号或者单引号包裹特殊字符
    - newline
      newline2    #字符串可以拆成多行，每一行会被转化成一个空格
date:
    - 2018-02-17    #日期必须使用ISO 8601格式，即yyyy-MM-dd
datetime: 
    -  2018-02-17T15:02:31+08:00    #时间使用ISO 8601格式，时间和日期之间使用T连接，最后使用+代表时区
```

### 特殊

```yaml
# --- 表示文件分割
server:
    address: 192.168.1.100
---
spring:
    profiles: development
    server:
        address: 127.0.0.1
---
spring:
    profiles: production
    server:
        address: 192.168.1.120

# ... 和 --- 配合使用，在一个配置文件中代表一个文件的结束
---
Time: 2018-02-17T15:02:31+08:00
User: ed
Warning: This is an error message for the log file
...
---
Time: 2018-02-17T15:05:21+08:00
User: ed
Warning: A slightly different error message.
...

# !! 类型强制转换
string:
  - !!str 54321 # 数字转 str
  - !!str true # bool 转 str

# > 折叠换行, | 保留换行符, 注意文本前要有空格  
# acc = line1 line2
acc: > 
 line1 
 line2
# sep = line1
#  line2
sep: | 
 line1 
 line2

# & 定义锚点，* 引用锚点
# {hr: [Mark McGwire, Sammy Sosa], rbi: [Sammy Sosa, Ken Griffey]}
hr:
  - Mark McGwire
  - &SS Sammy Sosa
rbi:
  - *SS 
  - Ken Griffey
```