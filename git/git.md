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

