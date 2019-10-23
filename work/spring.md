## 对 aspect 的解析
AbstractAdvisorAutoProxyCreator#findCandidateAdvisors() -> AnnotationAwareAspectJAutoProxyCreator#findCandidateAdvisors() -> BeanFactoryAspectJAdvisorsBuilder#buildAspectJAdvisors() 

## AOP 创建流程

- AbstractAutoProxyCreator#wrapIfNecessary(bean, beanName, cacheKey)

必要时创建增强

#### AbstractAutoProxyCreator#getAdvicesAndAdvisorsForBean()

从当前的 BeanFactory 中获取或创建增强 Advisors

- AbstractAdvisorAutoProxyCreator#findEligibleAdvisors()
  - AnnotationAwareAspectJAutoProxyCreator#findCandidateAdvisors()  
  从 BeanFactory 中找到所有的 Advisors, 并根据 @Aspect 创建 Advisors 并缓存

  - AbstractAdvisorAutoProxyCreator#findCandidateAdvisors()
  从 BeanFactory 中找到所有的 Advisors

#### AbstractAutoProxyCreator#createProxy

根据 Advisor 创建增强（即代理类）

