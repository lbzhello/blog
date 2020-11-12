## git commit 后如何撤销

```sh
# 撤销 commit，并且撤销git add . 操作
git reset HEAD^
```
> HEAD^ 标识上个 commit，等同于 HEAD~1
> 若撤销两个 commit, 则为 HEAD~2

-- mixed （默认参数）
不删除工作空间改动代码，撤销 commit，并且撤销 git add .

--soft
不删除工作空间改动代码，撤销 commit，不撤销 git add . 

--hard
删除工作空间改动代码，撤销commit，撤销git add . 

## git commit 后修改注释 
```sh
git commit --amend "new message"
```

## git log --name-status --author=liubaozhu --after=2020-05-01 --before=2020-05-31

查看每次提交改动的文件（不显示每个文件的改动信息）

## 统计改动的代码行数
```sh
git log --author="zhangxiao20" --since='2020-06-04' --until='2020-06-15' --pretty=tformat: --numstat | gawk '{ add += $1 ; subs += $2 ; loc += $1 - $2 } END { printf "增加的行数:%s 删除的行数:%s 总行数: %s\n",add,subs,loc }'
```


## git stash
[git stash 用法总结和注意点](https://www.cnblogs.com/zndxall/archive/2018/09/04/9586088.html)

暂存工作区代码，后面执行 git pull 拉取远程代码后，可以使用 git stash pop 恢复暂存的代码

## resotre
恢复文件至 head

```sh
# 错误删除文件
rm -f hello.c
# 恢复删除的文件
git restore hello.c  
# 恢复暂存区的文件
git restore --staged .
```
* --source master~2 恢复至两个版本前


[Git 天天用 但是 Git 原理你了解吗？](https://blog.csdn.net/ljk126wy/article/details/101064186)
[git-tips](https://github.com/jaywcjlove/git-tips)

## push

```
# 将本地 dev 分支提交到远程 dev 分支
git push origin dev

# 拉去远程 dev 分支到本地 dev 分支
git pull origin dev
```

## clean

清理本地没有加入到 git 的文件，又是后 pull 会报错 The following untracked working tree files would be overwritten by checkout


```
git clean -dx
```

-d **删除**未添加到 git 的文件，**注意文件是否还需要**
-x 
-f 强制执行，不会提示

## checkout

切换分支

#### 将另一个分支的某些文件合并到当前分支

[「小技巧」使用Git从其他分支merge个别文件](https://www.cnblogs.com/coderxx/p/11544550.html)

```sh
$ git branch
  * A  
    B
    
$ git checkout B message.html message.css message.js other.js

$ git status
# On branch A
# Changes to be committed:
#   (use "git reset HEAD <file>..." to unstage)
#
#    new file:   message.css
#    new file:   message.html
#    new file:   message.js
#    modified:   other.js
```

**注意：**这样会覆盖 A 分支文件，可以从 A 拉一个新分支 A_temp，在 A_temp 上 merge B 分支修改，在切换到 A 执行  git checkout A_temp message.html，这样就可以保留修改的文件