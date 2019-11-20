# Maven 教程

## 约定配置
Maven 提倡使用一个共同的标准目录结构，Maven 使用约定优于配置的原则，大家尽可能的遵守这样的目录结构。如下所示：

|目录|描述|
|:--|:--|
| ${basedir} | 存放 pom.xml 和所有的子目录 |
| ${basedir}/src/main/java | 项目的 java 源代码 |
| ${basedir}/src/main/resources | 项目的资源，比如说 property 文件，springmvc.xml |
| ${basedir}/src/test/java | 项目的测试类，比如说 Junit 代码 |
| ${basedir}/src/test/resources | 测试用的资源 |
| ${basedir}/src/main/webapp/WEB-INF | web 应用文件目录，web 项目的信息，比如存放 web.xml、本地图片、jsp 视图页面 |
| ${basedir}/target | 打包输出目录 |
| ${basedir}/target/classes | 编译输出目录 |
| ${basedir}/target/test-classes | 测试编译输出目录 |
| Test.java Maven | 只会自动运行符合该命名规则的测试类 |
| ~/.m2/repository | Maven 默认的本地仓库目录位置 |

## POM
所有 POM 文件都需要 project 元素和三个必需字段：groupId，artifactId，version。
```xml
<project xmlns = "http://maven.apache.org/POM/4.0.0"
    xmlns:xsi = "http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation = "http://maven.apache.org/POM/4.0.0
    http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <!-- 模型版本, 设为 4.0.0 -->
    <modelVersion>4.0.0</modelVersion>

    <!-- 工程组的唯一标识, 打包放本地路径为：/com/example/demo -->
    <groupId>com.example.demo</groupId>

    <!-- 项目的唯一ID，一个 groupId 下面可能多个项目，就是靠 artifactId 来区分的 -->
    <!-- groupId 和 artifactId 一起定义了 artifact 在仓库中的位置 -->
    <artifactId>project</artifactId>

    <!-- 版本号 -->
    <version>0.0.1-SNAPSHOT</version>
</project>
```

#### 父 POM
父（Super）POM是 Maven 默认的 POM。所有的 POM 都继承自一个父 POM（无论是否显式定义了这个父 POM）。父 POM 包含了一些可以被继承的默认设置。因此，当 Maven 发现需要下载 POM 中的 依赖时，它会到 Super POM 中配置的默认仓库 http://repo1.maven.org/maven2 去下载。

Maven 使用 effective pom（Super pom 加上工程自己的配置）来执行相关的目标，它帮助开发者在 pom.xml 中做尽可能少的配置，当然这些配置可以被重写。

[配置大全](pom.xml)

## Maven 生命周期

#### Maven 有三个标准的生命周期

1. clean 清除工程 target 目录下的内容
2. build 项目部署的处理
3. site  项目站点文档创建的处理

在一个生命周期中，运行某个阶段的时候，它之前的所有阶段都会被运行。

#### 构建阶段
开始 -> 验证(validate) -> 编译(compile) -> 测试(Test) -> 打包(package) -> 检查(verify) -> 安装(install) -> 部署(deploy)

| 阶段 | 处理 | 描述 |
|:----|:----|:----|
| validate | 验证 | 验证项目是否正确且所有必须信息是可用的 |
| compile  | 执行 | 源代码编译在此阶段完成 |
| test     | 测试 | 使用适当的单元测试框架（例如JUnit）运行测试。 |
| package  | 打包 | 创建JAR/WAR包如在 pom.xml 中定义的包 |
| verify   | 检查 | 对集成测试的结果进行检查，以保证质量达标 |
| install  | 安装 | 安装打包的项目到本地仓库，以供其他项目使用 |
| deploy   | 部署 | 拷贝最终的工程包到远程仓库中，以共享给其他开发人员和工程 |

#### 插件目标
一个插件目标代表一个特定的任务（比构建阶段更为精细），这有助于项目的构建和管理。这些目标可能被绑定到多个阶段或者无绑定。不绑定到任何构建阶段的目标可以在构建生命周期之外通过直接调用执行。这些目标的执行顺序取决于调用目标和构建阶段的顺序。

```shell
# clean 和 pakage 是构建阶段，dependency:copy-dependencies 是目标
# clean 阶段将会被首先执行，然后 dependency:copy-dependencies 目标会被执行，最终 package 阶段被执行。
mvn clean dependency:copy-dependencies package
```

### Clean 生命周期

**作用：** 清除工程 target 目录下的内容

1. pre-clean：执行一些需要在clean之前完成的工作
2. clean：移除所有上一次构建生成的文件
3. post-clean：执行一些需要在clean之后立刻完成的工作

### Build （Default）生命周期

### Site 生命周期
Maven Site 插件一般用来创建新的报告文档、部署站点等。

1. pre-site：执行一些需要在生成站点文档之前完成的工作
2. site：生成项目的站点文档
3. post-site： 执行一些需要在生成站点文档之后完成的工作，并且为部署做准备
4. site-deploy：将生成的站点文档部署到特定的服务器上

这里经常用到的是site阶段和site-deploy阶段，用以生成和发布Maven站点，这可是Maven相当强大的功能，Manager比较喜欢，文档及统计数据自动生成，很好看

## Maven 构建配置文件
构建配置文件是一系列的配置项的值，可以用来设置或者覆盖 Maven 构建默认值。

使用构建配置文件，你可以为不同的环境，比如说生产环境（Production）和开发（Development）环境，定制构建方式。

配置文件在 pom.xml 文件中使用 activeProfiles 或者 profiles 元素指定，并且可以通过各种方式触发。配置文件在构建时修改 POM，并且用来给参数设定不同的目标环境（比如说，开发（Development）、测试（Testing）和生产环境（Producation）中数据库服务器的地址）。

构建配置文件大体上有三种类型
1. 全局   Maven 安装目录下 conf/settings.xml
2. 用户级 用户目录下的 .m2/settings.xml
3. 项目级 项目的 POM 文件 pom.xml 中，只对当前项目有效

### Profile 
profile 可以让我们定义一系列的配置信息，然后指定其激活条件。这样我们就可以定义多个 profile，然后每个 profile 对应不同的激活条件和配置信息，从而达到不同环境使用不同配置信息的效果。

#### 配置不同的 profile

```xml
<profiles>
    <profile>
        <id>dev</id>
        <properties>
            <db.driver>com.mysql.jdbc.Driver</db.driver>
            <db.url>jdbc:mysql://localhost:3306/test</db.url>
            <db.username>root</db.username>
            <db.password>root</db.password>
        </properties>
    </profile>
    <profile>
        <id>prod</id>
        <properties>
            <db.driver>com.mysql.jdbc.Driver</db.driver>
            <db.url>jdbc:mysql://localhost:3306/test_db</db.url>
            <db.username>root</db.username>
            <db.password>root</db.password>
        </properties>
    </profile>
</profiles>
```

#### 激活 profile
1. 通过 -P 参数
```
mvn test -Pprod
```

2. 通过 settings.xml

```xml
<settings xmlns="http://maven.apache.org/POM/4.0.0"
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
   xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
   http://maven.apache.org/xsd/settings-1.0.0.xsd">
   ...
   <activeProfiles>
      <activeProfile>test</activeProfile>
   </activeProfiles>
</settings>
```

3. 默认激活
```xml
<profile>
    <id>dev</id>
    <activation>
        <activeByDefault>true</activeByDefault>
    </activation>
</profile>
```

## Maven 仓库
Maven 能帮助我们管理构件，它是存放 java 包(jar, war, zip 等)的地方

Maven 仓库两种类型本地仓库，远程仓库
#### 1. 本地仓库（local）  
运行 Maven 的时候，Maven 所需要的任何构件都是先从本地仓库获取的。如果本地仓库没有，它会首先尝试从远程仓库下载构件至本地仓库，然后再使用本地仓库的构件。

**默认位置：** 用户目录下 .m2/respository 

可以通过 settings.xml 修改默认位置

```xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
   xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 
   http://maven.apache.org/xsd/settings-1.0.0.xsd">
      <localRepository>/path/to/myrepository</localRepository>
</settings>
```


#### 2. 远程仓库（remote）

公司或组织自己定制仓库，包含了所需要的代码库或者其他工程中用到的 jar 文件。

可以通过 settings.xml 或者 pom.xml 制定仓库地址

> 中央仓库（central）
Maven 中央仓库是由 Maven 社区提供的远程仓库，其中包含了大量常用的库。中央仓库包含了绝大多数流行的开源Java构件，以及源码、作者信息、SCM、信息、许可证信息等。一般来说，简单的Java项目依赖的构件都可以在这里下载到。  

> Maven 中央仓库位置：https://search.maven.org/#browse

### 仓库配置

中央仓库的速度比较慢，可以使用国内的仓库

**阿里云**   

settings.xml
```xml
<mirrors>
    <mirror>
      <id>alimaven</id>
      <name>aliyun maven</name>
      <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
      <mirrorOf>central</mirrorOf>        
    </mirror>
</mirrors>
```

## Maven 插件
Maven 生命周期的每一个阶段的具体实现都是由 Maven 插件实现的。比如 mvn clean，clean 对应的就是 Clean 生命周期中的 clean 阶段。但是 clean 的具体操作是由 maven-clean-plugin 来实现的。

插件通常提供了一个目标的集合，并且可以使用下面的语法执行：

```shell
mvn [plugin-name]:[goal-name]
```

例如，一个 Java 工程可以使用 maven-compiler-plugin 的 compile-goal 编译，使用以下命令：

```
mvn compiler:compile
```

