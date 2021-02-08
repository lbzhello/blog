# Git 常用操作

# 创建仓库

**新建仓库**

```sh
# 在当前文件夹初始化一个本地 git 仓库
git init 

# 添加远程版本库
git remote add origin "xxx.git"

# 从远程仓库 clone 一个仓库
git clone <url>
```

# 分支管理

## 创建分支

```sh
# 新建 temp 分支
git branch temp

# 从 commitId 新建分支 temp, 默认根据当前分支拉取
git branch temp [commit-id]

# 根据 commitId 新建切换到 temp 分支，默认根据当前分支拉取
git checkout -b temp [commit-id]
```

## 删除分支

```sh
# 删除 temp 分支 -D 强制删除
git branch -d temp
```

## 追踪分支

```sh
# 列出所有分支
git branch -a

# 显示当前分支追踪的远程分支
git branch -vv

# 使 dev 分支跟踪 origin/dev 分支，默认当前分支
git branch --set-upstream-to=origin/dev [dev]
```

# 合并

## 使用 rebase 合并 temp 分支到当前分支

 rebase 合并分支后只保留一条提交记录

```sh
git rebase temp

# 如果遇到冲突
# 解决冲突后继续
git add .
git rebase --continue

# 最后提交分支
git push
```

如果 ```git rebase --continue``` 后出现：No changes - did you forget to use 'git add'?

这是因为解决冲突后没有改动的文件，比如合并时全部选择 Accept Theirs

这时需要使用 --skip 选项，使 rebase 流程继续执行

```sh
git rebase --skip 
```

如果想要取消本次 rebase, 回到 rebase 开始前的状态

```sh
git rebase --abort
```

## 使用 merge 合并 temp 分支到当前分支

merge 合并后会保留每次提交记录，如果提交次数很多建议使用 rebase

```sh
git merge temp

# 遇到冲突
git add .
3. git commit #继续执行 merge
```


