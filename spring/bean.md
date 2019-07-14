## Annotation 创建 bean 流程

#### BeanDefinition bean定义接口，
1. AnnotatedBeanDefinition 额外提供 AnnotationMetadata 信息

## Bean创建流程

#### Bean创建接口

    public AnnotationConfigApplicationContext(Class<?>... annotatedClasses) {
		this();
		register(annotatedClasses);
		refresh();
	}
