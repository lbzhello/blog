#### echo
打印字符，后接 >> 可以输出到指定位置

```shell
# 打印到控制台
echo "hello"

# 输出到文件 file.txt
echo "hello" >> file.txt
```

#### 变量
```shell
# 变量声明, = 两边不能有空格
msg=hello
msg2="hello"

# 使用变量, 前面加 $ 符号, 或者 ${}
echo $msg
echo ${msg}

# unset 删除变量
unset msg

# 只读变量，不能改变，不能删除
readonly msg
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

$ # [] 测试表达式，同 test， [[]] 是其加强版
$ # [ exp ] exp 两边要有空格
$ [ 2==5 ]

false

$ # () 和 {} 用于执行一串命令，命令间用 ; 隔开
$ # (cmd1;cmd2;cmd3) 重开一个 shell
$ (tmp=hello;echo $tmp)

hello

$ # { cmd1;cmd2;cmd3; } 在当前 shell 中运行
$ # 括号和表达式之前要有空格，最后一个表达式需要 ; 符号
$ [ tmp=hello;echo $tmp; ]

hello
 
```


**算数运算符**

expr 可以执行算数运算
```shell
# + 两边要有空格
expr 2 + 2

# 提取结果，` 是反引号
val=`expr 2 * 2`
val=${expr 2 + 2}
echo "结果为：$val"

# 

```
