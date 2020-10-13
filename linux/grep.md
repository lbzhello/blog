# grep
强大的文本搜索工具

## 常用选项
```
-A <N> --after-context=<N> #显示该列之后 N 行的内容
-B <N> --before-context=<N> #显示该列之前 N 行的内容
-c --count  #计算符合范本样式的行数，只会显示统计数字
-C <N> --context=<N> 或 -<N>  #除了显示符合范本样式的那一列之外，并显示该列之前之后 N 行的内容
-e <PATTERN> --regexp=<PATTERN>  #正则匹配
-E <PATTERN> --extended-regexp=<PATTERN>  #扩展正则表达式
-m <N> --max-count=<num> #做多匹配 N 次
-E --extended-regexp  # 使用能使用扩展正则表达式。
-P --perl-regexp=<PATTERN>  #PATTERN 是一个 Perl 正则表达式，支持 \d 等
-v --revert-match  #反转查找，输出除之外的所有行选项
-n --line-number  # 在显示符合范本样式的那一列之前，标示出该列的编号。
-i --ignore-case    # 忽略字符大小写的差别
-r/-R --recursive  #递归查找目录下的文件，此参数的效果和指定“-d recurse”参数相同
```

## 示例

从文件 test.log 中匹配含有 debug 的行
```sh
grep 'debug' /path/to/test.log
```

从文件 test.log 中匹配含有 debug 的行，显示行号（-n），显示之后 2 行的内容(-A 2)
```sh
grep 'debug' /path/to/test.log -n -A 2
```

匹配含有 debug 或 info 的行
```sh
# -E 表示使用正则
grep -E 'debug|info' /path/to/test.log

# 或
egrep 'debug|info' /path/to/test.log
```

结合管道使用，匹配含有 debug 和 info 的行
```sh
grep 'debug' /path/to/test.log | grep 'info'
```
