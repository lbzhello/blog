[SpringBoot使用Validation校验参数](https://blog.csdn.net/justry_deng/article/details/86571671)

## @Validated 
在需要验证的对象或类上， 不支持嵌套，需要在嵌套模型字段前加 @Valid 注解

## @Valid
javax 注解，支持嵌套

# 分组
定义接口，可以继承 Default 接口（表示包含 Default 组）

# Spring Validation的3种执行校验方式
第一种：在Controller方法参数前加@Valid注解——校验不通过时直接抛异常

```java
 /**
 * 校验不通过时直接抛异常
 * @param user
 * @return
 */
@PostMapping("/test1")
public Object test1(@RequestBody @Valid User user) {
	return "操作成功！";
}
```

第二种：在Controller方法参数前加@Valid注解，参数后面定义一个BindingResult类型参数——执行时会将校验结果放进bindingResult里面，用户自行判断并处理

```java
/**
 * 将校验结果放进BindingResult里面，用户自行判断并处理
 * @param user
 * @param bindingResult
 * @return
 */
@PostMapping("/test2")
public Object test2(@RequestBody @Valid User user, BindingResult bindingResult) {
	// 参数校验
	if (bindingResult.hasErrors()) {
		String messages = bindingResult.getAllErrors()
			.stream()
			.map(ObjectError::getDefaultMessage)
			.reduce((m1, m2) -> m1 + "；" + m2)
			.orElse("参数输入有误！");
		throw new IllegalArgumentException(messages);
	}
	
	return "操作成功！";
}
```


第三种：用户手动调用对应API执行校验——Validation.buildDefaultValidatorFactory().getValidator().validate(xxx)

```java
/**
 * 用户手动调用对应API执行校验
 * @param user
 * @return
 */
@PostMapping("/test3")
public Object test3(@RequestBody User user) {
	// 参数校验
	validate(user);
	
	return "操作成功！";
}

private void validate(@Valid User user) {
	Set<ConstraintViolation<@Valid User>> validateSet = Validation.buildDefaultValidatorFactory()
			.getValidator()
			.validate(user, new Class[0]);
		if (!CollectionUtils.isEmpty(validateSet)) {
			String messages = validateSet.stream()
				.map(ConstraintViolation::getMessage)
				.reduce((m1, m2) -> m1 + "；" + m2)
				.orElse("参数输入有误！");
			throw new IllegalArgumentException(messages);
			
		}
}
```