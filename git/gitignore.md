以 / 开头表示根路径（.git 所在目录），否则表示所有文件

\#      用于注释

\*      匹配除'\'之外的多个所有字符。比如 *.txt 匹配所有 txt 文件

/path/  忽略 path 目录下的所有文件，不忽略 path 目录

/path   忽略跟（.git 所在目录） path 目录，包含 path

path    忽略当前（.gitignore 所在目录） path 目录以及下面的文件 

!       取反，不忽略。例如 /path/to !/path/to/file.txt，忽略目录 /path/to 下所有文件，不忽略 /path/file.txt 文件

?       匹配除'\'之外的一个所有字符。例： path?.txt 可以匹配到 patha.txt、pathk.txt等文件

[]      匹配数组中指定指定的字符。例：path[k,l] 可以匹配到 pathk.txt、pathl.txt， 之外都不行

**      用于匹配多层目录。例: root/**/path 可以匹配到 root/a/b/c/path 、root/fd/gg/path等目录


## .gitignore规则不生效
.gitignore 只能忽略那些原来没有被 track 的文件，如果某些文件已经被纳入了版本管理中，则修改 .gitignore 是无效的。

解决方法就是先把本地缓存删除（改变成未track状态），然后再提交:
```
git rm -r --cached .
git add .
git commit -m 'update .gitignore'
```