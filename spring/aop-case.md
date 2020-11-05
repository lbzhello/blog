```java
https://blog.csdn.net/ysl19910806/article/details/91898875
@Aspect
public class LogAspects {
	
	//抽取公共的切入点表达式
	//1、本类引用
	//2、其他的切面引用
	@Pointcut("execution(public int com.spring.aop.MathCalculator.*(..))")
	private void pointCut(){};
	
	//@Before在目标方法之前切入；切入点表达式（指定在哪个方法切入）
	//JoinPoint一定要出现在参数列表的第一位
	@Before(value = "pppointCut()")
	public void logStart(JoinPoint joinpoint) {
		System.out.println("logStart>>>>"+joinpoint.getSignature().getName()+">>>>"+Arrays.toString(joinpoint.getArgs()));
	}
 
	@After(value ="com.spring.aop.LogAspects.pppointCut()")
	public void logEnd(JoinPoint joinpoint) {
		System.out.println("logEnd>>>>>"+joinpoint.getSignature().getName()+">>>>"+Arrays.toString(joinpoint.getArgs()));
	}
 
	@AfterReturning(value ="execution(public int com.spring.aop.MathCalculator.*(..))",returning="object")
	public void logReturn(Object object) {
		System.out.println("logReturn>>>>"+object);
	}
 
	@AfterThrowing(value = "execution(public int com.spring.aop.MathCalculator.*(..))",throwing = "object")
	public void logException(Exception object) {
		System.out.println("logException>>>>"+object);
	}
 
}

```