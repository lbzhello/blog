## IDEA 引入了 jar 包但提示“Cannot resolve symbol XXX”
方法1：.gitignore 是否忽略了对应的文件或路径，Editor -> File Types -> Ignore files and folders 是否忽略了对应的路径或文件？（很有可能）
方法2： “File” -> “Invalidate Caches / Restart”→ “Invalidate and Restart”
方法3： 删除 .idea, 重新导入项目

[idea无法引用jar包中的class](https://www.cnblogs.com/alvwood/p/10944912.html)

## 符号不存在

File -> Project Structure -> Modules 看看是否有多个项目，删掉无用的。或者调整一下项目，重新 Mark as 一下，指定成 Sources