#### echo
打印字符，后接 >> 可以输出到指定位置

```shell
# 打印到控制台
$ echo "hello world"

hello world

$ # 可以不用引号
$ echo hello world

hello world

$ # 输出到文件 file.txt
$ # > 表示覆写， >> 表示追加
$ echo "hello hello" >> file.txt
```

#### 变量
```shell
# 变量声明, = 两边不能有空格
$ msg=hello
$ msg2="hello"

# 使用变量, 前面加 $ 符号, 或者 ${}
$ echo $msg

hello

$ echo ${msg}

hello

# unset 删除变量
$ unset msg

# 只读变量，不能改变，不能删除
$ readonly msg
```

#### 字符串
```shell
# 双引号支持嵌入变量，转义字符等
name="word"
str="hello \"$name\"\n" # hello "word"

# 单引号保持原义输出
str='hello $name' # hello $name

# 字符串拼接
str="hello "$name" !" # hello world !

msg="hello"
# # 获取字符串长度
echo ${#msg} # 5

# 截取字符串
echo ${msg:1:2} # el
```

#### 数组
```shell
arr=(v1 v2 v3 v4)
# 或者
arr=(
v1
v2
v3
v4
)
# 或者,下标可以不连续
arr[0]=v1
arr[1]=v2
arr[3]=v3
arr[8]=v4

# 读取数组
value=${arr[2]}

# @ 或 * 下标获取所有元素
echo ${arr[@]}
echo ${arr[*]}

# # 获取数组长度
echo ${#arr[@]}

```

#### 参数
$n 获取参数，n 为一个数字, 0 表示命令本身，1 表示第一参数，依次类推

创建脚本文件： test.sh
```shell
#!/bin/bash
# author: lbz
# fileName: test.sh

echo "Shell 传递参数实例！";
echo "执行的文件名：$0";
echo "第一个参数为：$1";
echo "第二个参数为：$2";
echo "第三个参数为：$3";
```

执行脚本
```shell
$ sh test.sh 1 2 3
Shell 传递参数实例！
执行的文件名：test.sh
第一个参数为：1
第二个参数为：2
第三个参数为：3
```

特殊参数处理

```shell
$# # 传递到脚本的参数个数
$* # 以字符串形式显示所有参数，输出 $0 $1 $2 ... $n
$@ # 以字符串形式显示所有参数，输出 $0 $1 $2 ... $n
$$ # 当前进程ID号 
$! # 最后一个进程的ID号
$- # 显示Shell使用的当前选项, 同 set
$? # 显示最后命令的退出状态。0表示没有错误，其他任何值表明有错误
```

#### 括号表达式
关于 ${}, $(), $(()) 详细可参考[这里](https://www.cnblogs.com/xunbu7/p/6187017.html)

```shell
$ file=/dir1/dir2/dir3/my.file.txt
$
$ # ${var} 变量替换, 支持模式匹配
$ echo ${file}

/dir1/dir2/dir3/my.file.txt


$ # $(cmd) 命令替换，同 `` 反引号
$ echo value is $(expr 5 + 2)

value is 7

$ # $(()) 是 C 语言整数运算符扩展，和 $[] 相同
$ a=2
$ b=3
$ echo $((a + b))

5

$ # 支持所有的 C 整数运算符
$ echo $((c=a+b))

5

$ echo $((++c))

6

$ # [] 测试表达式，同 test， 返回 0 表示真
$ # [ exp ] exp 两边要有空格
$ # [[]] 提供字符串判断加强; (()) 提供数值表达式功能 
$
$ # [ -n "$a" ] 判断非空,需要加引号
$ [ -n "$a" ]
$ echo $?

0

$ # [[]] 可直接使用 -z -n 判断是否为空
$ [[ -n $a ]]
$ echo $?

0

$ # (()) 运算符可以不用转义，支持更多运算
$ ((a++))

$ # () 和 {} 用于执行一串命令，命令间用 ; 隔开
$ # (cmd1;cmd2;cmd3) 重开一个 shell
$ (tmp=hello;echo $tmp)

hello

$ # { cmd1;cmd2;cmd3; } 在当前 shell 中运行
$ # 括号和表达式之前要有空格，最后一个表达式需要 ; 符号
$ [ tmp=hello;echo $tmp; ]

hello
 
```

#### 运算符

**算数运算符**

$(()) 可以执行算数运算
```shell
$ echo $((3 + 2))

5

$ i=1
$ val=$((i++))
$ echo $val

2
```

也可以使用 expr 命令执行数学计算，详细可 ```info expr``` 查看如何使用

**关系运算符**

关系运算符只支持数字，[] 中只能使用转义字符，[[]] 中可以使用符号

|[ op ]  |-eq|-ne|-gt|-lt|-ge|-le|
|--------|---|---|---|---|---|---|
|[[ op ]]|== |!= | > | < |>= |<= |

```shell
#!/bin/bash
# author: lbz

a=10
b=20

# [] 运算符
if [ $a -eq $b ]
then
   echo "$a -eq $b : a 等于 b"
else
   echo "$a -eq $b: a 不等于 b"
fi

# [[]] 运算符
if [[ $a == $b ]
then
   echo "$a == $b: a 不等于 b"
else
   echo "$a == $b : a 等于 b"
fi
```

**逻辑运算符**

[] 使用转义字符，[[]] 可以直接使用

|[ op ]  |!|-o|-a|
|--------|---|---|---|
|[[ op ]]|! |\|\| | && |

```shell
#!/bin/bash
# author: lbz

a=10
b=200

if [ $a -lt 100 -o $b -gt 100 ]
then
   echo "返回 true"
else
   echo "返回 false"
fi

if [[ $a -lt 100 || $b -gt 100 ]]
then
   echo "返回 true"
else
   echo "返回 false"
fi
```

**字符串判断**

|符号|说明|示例|
|--|--|--|
|==|字符串相等返回 true|[ $a == $b ] |
|!=|字符串不相等返回 true|[ $a != $b ] |
|-z|字符串长度是为0返回 true|[ -z $a ] |
|-n|字符串长度是不为0返回 true|[ -n "$a" ]|
|$|字符串不为空返回 true|[ -n "$a" ]|

示例：

```shell
#!/bin/bash
# author: lbz

a="hello"

if [ -n $a ]
then
   echo "a 长度不为 0"
else
   echo "a 长度为 0"
fi
```

**文件判断**

文件判断符号

|符号|说明|
|----|--|
| -e |检测文件（包括目录）是否存在，如果是，则返回 true|
| -f |检测文件是否是普通文件（既不是目录，也不是设备文件），如果是，则返回 true|
| -d |检测文件是否是目录，如果是，则返回 true|
| -s |检测文件是否为空（文件大小是否大于0），不为空返回 true|
| -r |检测文件是否可读，如果是，则返回 true|
| -w |检测文件是否可写，如果是，则返回 true|
| -x |检测文件是否可执行，如果是，则返回 true|
| -b |检测文件是否是块设备文件，如果是，则返回 true|
| -c |检测文件是否是字符设备文件，如果是，则返回 true|
| -g |检测文件是否设置了 SGID 位，如果是，则返回 true|
| -k |检测文件是否设置了粘着位(Sticky Bit)，如果是，则返回 true|
| -p |检测文件是否是有名管道，如果是，则返回 true|
| -u |检测文件是否设置了 SUID 位，如果是，则返回 true|

示例：

```shell
#!/bin/bash
# author: lbz

file=/path/to/text.txt

# -d 标志判断是否为目录
if [ -d $file ]
then
   echo "$file 是目录"
else
   echo "$file 是文件"
fi
```

#### 流程控制

#### if

```shell
# if 
if condition
then
    command1 
    command2
    ...
    commandN
fi

# if else
if condition
then
    command1 
    command2
    ...
    commandN
else
    command
fi

# if elif
if condition1
then
    command1
elif condition2 
then 
    command2
else
    commandN
fi

# 写在一行, 表达式后面加 ; 符号
if condition; then command1; command2; ...; commandN; else command; fi
```

#### for

```shell
# 格式
for var in item1 item2 ... itemN
do
    command1
    command2
    ...
    commandN
done

# 写在一行
for var in item1 item2 ... itemN; do command1; command2; ...; commandN; done
```

#### while

```shell
while condition
do
    command
done

# 写在一行
while condition; do command; done
```

#### until

条件为 true 时停止

```shell
until condition
do
    command
done

# 写在一行
until condition; do command; done
```

#### case

```shell
case 值 in
模式1)
    command1
    command2
    ...
    commandN
    ;;
模式2）
    command1
    command2
    ...
    commandN
    ;;
esac
```

#### break，continue

break 跳出循环，continue 跳出本次循环，和其他语言一致


## 函数
function 关键字可以省略；函数参数用 $n 表示，$1 表示第 1 个参数

```shell
function funname() {
    command1
    command2
    ...
    commandN
    return rst
}

```

```shell
#!/bin/bash
function fun1(){
    echo "这是我的第一个 shell 函数!"
    return `expr $1 + $2`
}

# 函数调用
fun1 3 2

# 获取函数返回值
echo $?

# 函数可以用作条件判断
# 注意 shell 会把 0 当做 true，其他所有值表示 false
if fun1 1 2
then
   echo true
else
   echo false
fi
```
