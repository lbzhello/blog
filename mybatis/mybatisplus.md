[mybatis-plus的使用 ------ 入门](https://www.jianshu.com/p/ceb1df475021)

[Mybatis-plus函数及用法实例](https://blog.csdn.net/weixin_42577140/article/details/89841799)

[Mybatis-Plus使用全解](https://blog.csdn.net/weixin_33850015/article/details/92431309)

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

## 查询时typeHandler 不生效问题

@TableName 的 autoResultMap 设为 true

```java
@Getter
@Setter
@TableName(autoResultMap = true)
public class TbOcr {
    @TableId(type = IdType.AUTO)
    private Integer id;
	
	@TableField(typeHandler = JsonbTypeHandler.class)
	private Object jsonField;
}
```

typeHandler

```java
public class JsonbTypeHandler implements TypeHandler {
    @Override
    public void setParameter(PreparedStatement ps, int i, Object parameter, JdbcType jdbcType) throws SQLException {
        PGobject ext = new PGobject();
        ext.setType("jsonb");
        ext.setValue(String.valueOf(parameter));
        ps.setObject(i, ext);
    }

    @Override
    public Object getResult(ResultSet rs, String columnName) throws SQLException {
        String json = rs.getString(columnName);
        return json;
    }

    @Override
    public Object getResult(ResultSet rs, int columnIndex) throws SQLException {
        return null;
    }

    @Override
    public Object getResult(CallableStatement cs, int columnIndex) throws SQLException {
        return null;
    }
}
```