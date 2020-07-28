## 构建基础

gradle 命令会从当前目录下寻找 build.gradle 文件来执行构建。我们称 build.gradle 文件为构建脚本。

任何一个 Gradle 构建都是由一个或多个 project 组成；每个 project 都由多个 task 组成。

**projects 和 tasks 是 gradle 中最重要的两个概念。**

build.gradle 构建脚本定义了一个 project 和一些默认的 task。

## projiects
每个 project 包括许多可构建组成部分。 这完全取决于你要构建些什么。举个例子，每个 project 或许是一个 jar 包或者一个 web 应用，它也可以是一个由许多其他项目中产生的 jar 构成的 zip 压缩包。一个 project 不必描述它只能进行构建操作。它也可以部署你的应用或搭建你的环境。

## tasks
 task 代表了构建执行过程中的一个原子性操作。如编译，打包，生成 javadoc，发布到某个仓库等操作。

## hello world

build.gradle

```gradle
task hello {
    doLast {
        println 'hello world!'
    }
}
```

在该文件所在目录执行：

```sh
> gradle -q hello
hello world!
```
> -q 参数表示只输出想要的内容

上面的脚本定义了一个叫做 hello 的 task，并且给它添加了一个动作。当执行 gradle hello 的时候, Gralde 便会去调用 hello 这个任务来执行给定操作。

[](https://www.cnblogs.com/mooreliu/p/4849898.html)