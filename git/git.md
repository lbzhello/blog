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
* --git restore --staged <file>... 撤销 git add


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

## 用一个分支的代码覆盖另一个分支

如：当前分支是maser分支，我想讲paytest分支上的代码完全覆盖master分支，首先切换到master分支。
```
 git reset --hard origin/paytest
```

执行上面的命令后master分支上的代码就完全被paytest分支上的代码覆盖了（本地分支），然后将本地分支强行推到远程分支。
```
git push -f
```

## cherry-pick
http://www.ruanyifeng.com/blog/2020/04/git-cherry-pick.html
对于多分支的代码库，将代码从一个分支转移到另一个分支是常见需求。

这时分两种情况。一种情况是，你需要另一个分支的所有代码变动，那么就采用合并（git merge）。另一种情况是，你只需要部分代码变动（某几个提交），这时可以采用 Cherry pick。

将 commitHash 提交应用于当前分支
```
git cherry-pick <commitHash>
```

如果只想选出来, 不想提交, 则使用 -n 参数, 例: git cherry-pick -n ef9bd946044727fee070a644d527ddc9d970f18d .

去过 cherry-pick 过程中发生冲突， cherry-pick 会停下来，让用户决定如何继续

1. --continue 用户解决代码冲突后，第一步将修改的文件重新加入暂存区（git add .），第二步使用此 ```git cherry-pick --continue``` 命令，让 Cherry pick 过程继续执行。
2. --abort 发生代码冲突后，放弃合并，回到操作前的样子。
3. --quit 发生代码冲突后，退出 Cherry pick，但是不回到操作前的样子。

## 分支
删除远程 dev 分支
```
git push origin --delete dev
```

删除本地 dev 分支
```
git branch -d dev
```

## rebase
https://www.cnblogs.com/FineDay/p/10905836.html
合并多个 commit

```
git rebase -i [commitId]
```
> 要将最近的 2 个 commit 合并成一个，则 commitId 为第三次的 commitId

**选项**
pick 的意思是要会执行这个 commit
squash 的意思是这个 commit 会被合并到前一个commit

[git rebase和git merge的区别](http://blog.sina.com.cn/s/blog_14c2211450102vp66.html)

```sh
# 合并 branchName 的改动到当前分支 
git rebase branchName
```

**git rebase 遇到冲突**
1. 解决冲突
2. git add <修改>
3. git rebase —continue #继续操作；或者 git rebase —skip 忽略冲突；或者 git rebase —abort 撤销 rebase 操作

## merge
```sh
git merge branch-name
```

**git merge 遇到冲突**
1. 解决冲突
2. git add <修改>
3. git commit #继续执行 merge

## revert

```sh
git revert -n commit-id
```

回退 commit-id 提交，-n 表示不自动提交

