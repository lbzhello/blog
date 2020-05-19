[mybatis-plus的使用 ------ 入门](https://www.jianshu.com/p/ceb1df475021)

https://blog.csdn.net/weixin_42577140/article/details/89841799

<plugin>
	<groupId>org.mybatis.generator</groupId>
	<artifactId>mybatis-generator-maven-plugin</artifactId>
	<version>1.4.0</version>
	<configuration>
		<!-- 在控制台打印执行日志 -->
		<verbose>true</verbose>
		<!-- 重复生成时会覆盖之前的文件-->
		<overwrite>true</overwrite>
		<configurationFile>src/main/resources/generatorConfig.xml</configurationFile>
	</configuration>
	<dependencies>
		<dependency>
			<groupId>org.postgresql</groupId>
			<artifactId>postgresql</artifactId>
			<version>42.2.10</version>
		</dependency>
	</dependencies>
</plugin>