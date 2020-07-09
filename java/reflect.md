## 获取泛型 T 的 Class

## getGenericSuperclass 
获取父类信息，如果父类是参数化类型，则类中必须带有参数化类型信息

```java
// 获取泛型参数
Type type = this.getClass().getGenericSuperclass();
// 获取第一个实际泛型
Type typeArgument = ((ParameterizedType) type).getActualTypeArguments()[0];
// 转为 Class
Class<T> clazz = (Class<T>)typeArgument;
```