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

## idea gradle 下载缓慢的问题

在项目的 gradle/wrapper/gradle-wrapper.properties 下有如下配置

```prop
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-6.5.1-all.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
```

先下载 gradle zip 包，将 **distributionUrl** 指向本地 zip 位置   

```prop
distributionUrl=file:///D:/Software/gradle/gradle-6.5.1-all.zip
```

## implementation 和 compile

a --依赖--> b --依赖--> c

如果 b 中 implementation c, a 无法访问 c 提供的接口，即**将该依赖隐藏在内部，而不对外部公开**

## allprojects
所有项目共享配置

## subprojects
子项目共享配置

## ext
统一管理版本号

```
ext {
    junitVersion = "4.11"
    springVersion = "4.3.3.RELEASE"
    jacksonVersion = "2.4.4"
    compileJava.options.encoding = 'UTF-8'
    compileTestJava.options.encoding = 'UTF-8'
}
```
引用：
```
项目版本:
def cfg = rootProject.ext.configuration
cfg.compileVersion
库版本:
def libs = rootProject.ext.libraries
${libs.retrofit}
```

## 统一project(p), a 模块 引入 b 模块
先在 p 中的 settings.gradle 中声明子模块, 然后在 a 的 build.gradle 中声明对 b 的依赖

```
dependencies { 
    compile project(":b")
} 
```
