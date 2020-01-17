## SpringMVC 三种异常处理方式

在 SpringMVC， SpringBoot 处理 web 请求时， 若遇到错误或者异常，返回给用户一个良好的错误信息比 Whitelabel Error Page 好的多。 SpringMVC 提供了三种异常处理方式， 良好的运用它们可以给用户提供可读的错误信息。

#### 1. 实现 HandlerExceptionResolver

```java
@Conponent
public class AppHandlerExceptionResolver implements HandlerExceptionResolver {
    @Override
    public ModelAndView resolveException(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
        ModelAndView mav = new ModelAndView();
        mav.addObject("message", ex.getMessage());
        // 可以设置视图名导向错误页面
        mav.setViewName("/error");
        // 直接返回视图
        // 如果返回 null，则会调用下一个 HandlerExceptionResolver
        return mav;
    }
}
```

HandlerExceptionResolver 的实现类能捕获到 @Controller 方法执行时发生的异常，处理后返回 ModelAndView 作为结果视图，因此可以通过它来定制异常视图。

HandlerExceptionResolver 只能捕获 @Controller 层发生的异常（包括 @Controller 调用 @Service 发生的异常），其他地方的异常，比如访问了一个不存在的路径，不会被 HandlerExceptionResolver 捕获，此时会跳到 ErrorController 处理， 下面会说到。

#### 2. 通过 @ControllerAdvice 和 @ExceptionHandler 注解

```java
// 可以配置拦截指定的类或者包等
// @RestControllerAdvice 相当于 @ExceptionHandler + @ResponseBody
// basePackageClasses 指定类所在的包，可以添加一个空类或接口表示一个包。
// 可以不指定包名，默认拦截所有指定的异常
@RestControllerAdvice(basePackageClasses = HelloWorldController.class)
public class AppExceptionHandlerAdvice {

    // 配置拦截的错误类型
    // 这里也可以返回 ModelAndView 导向错误视图
    // 不指定异常则根据参数进行拦截
    @ExceptionHandler(Exception.class)
    public ResponseEntity<Object> responseEntity(Exception e) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON_UTF8);
        Map<String, Object> map = new HashMap<>();
        map.put("status", 400);
        map.put("message", e.getMessage());
        // 直接返回结果
        return new ResponseEntity<>(map, headers, HttpStatus.BAD_REQUEST);

    }
}
```

这种方式配置的异常处理由 HandlerExceptionResolver 的默认实现类 HandlerExceptionResolverComposite 处理，因此也只能捕获 @Controller 层的异常。

@ExceptionHandler 可以返回 ModelAndView 导向异常视图。

@ControllerAdvice 可以拦截特定的类，@ExceptionHandler 可以拦截特定的异常，因此可以更精确的配置异常处理逻辑。

> @ExceptionHandler 可以在 @Controller 类中声明，此时只能处理同一个类的异常

#### 3. 实现 ErrorController 接口

这里为了方便，直接继承 AbstractErrorController

```java
@RestController
@RequestMapping("/error")
public class AppErrorController extends AbstractErrorController {

    public AppErrorController(ErrorAttributes errorAttributes) {
        super(errorAttributes);
    }

    @RequestMapping
    public ResponseEntity<Map<String, Object>> error(HttpServletRequest request) {
        Map<String, Object> body = getErrorAttributes(request, false);
        HttpStatus status = getStatus(request);
        // 返回响应体
        return new ResponseEntity<>(body, status);
    }

    @Override
    public String getErrorPath() {
        return "/error";
    }
}
```

如果没有配置 ErrorController, SpringBoot 会通过 ErrorMvcAutoConfiguration 自动配置一个，默认的实现类为 BasicErrorController。

ErrorController 可以处理非 @Controller 层抛出的异常，例如常见的访问了一个不存在的路径。

ErrorController 可以进行统一的错误处理，即让 HandlerExceptionResolver 返回的 ModelAndView 导向错误页面。


