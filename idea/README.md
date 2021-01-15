## 项目 sdk 不一致
1. 配置 sdk 
Ctrl + Shift + Alt + S 打开项目配置；
选择 SDKs， 点击 + 或 - 添加 SDK；
选择 Project，修改 Project SDK 和 Project language level JDK 版本；
选择 Modules，选中某个项目或模块，修改 Sources 下面的 Language level；Dependencies 下面的 Module SDK 为 Project SDK；

2. Java Compile
Ctrl + Shift + A, 输入 “Java Compile”，将 Project bytecode version 修改为需要的版本；

3. 构建工具（Gradle Maven）
Ctrl + Shift + A, 输入 “Build Tools”;
对于 Gradle, 修改 Gradle JVM 为需要的版本；
对于 Maven, 修改 Runner 下面的 JRE, 和项目 JDK 版本保持一致；