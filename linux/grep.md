# grep
强大的文本搜索工具

## 常用选项
```
-c --count  #计算符合范本样式的行数，只会显示统计数字
-C <N> --context=<N> 或 -<N>  #除了显示符合范本样式的那一列之外，并显示该列之前之后 N 行的内容
-e <PATTERN> --regexp=<PATTERN>  #正则匹配
-E <PATTERN> --extended-regexp=<PATTERN>  #扩展正则表达式
-P --perl-regexp=<PATTERN>  #PATTERN 是一个 Perl 正则表达式，支持 \d 等
-v --revert-match  #反转查找，输出除之外的所有行选项
-n --line-number  # 在显示符合范本样式的那一列之前，标示出该列的编号。
-r/-R --recursive  #递归查找目录下的文件，此参数的效果和指定“-d recurse”参数相同
```