## SpringMVC 三种异常处理方式

在 SpringMVC， SpringBoot 处理 web 请求时， 若遇到错误或者异常，返回给用户一个良好的错误信息比 Whitelabel Error Page 好的多。 SpringMVC 提供了三种异常处理方式， 良好的运用它们可以给用户提供可读的错误信息。

#### 1. 通过实现 HandlerExceptionResolver

```java
public class AppHandlerExceptionResolver implements HandlerExceptionResolver {
    @Override
    public ModelAndView resolveException(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
        ModelAndView mav = new ModelAndView();
        mav.addObject("error", ex.getMessage());
        return mav;
    }
}
```

#### 2. 通过 ControllerAdvice 和 @ExceptionHandler 注解

```java
@RestControllerAdvice
public class AppExceptionHandlerAdvice {

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Object> responseEntity(Exception e) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON_UTF8);
        Map<String, Object> map = new HashMap<>();
        map.put("status", 400);
        map.put("message", e.getMessage());
        return new ResponseEntity<>(map, headers, HttpStatus.BAD_REQUEST);

    }
}
```

#### 3. 通过自定义 ErrorController bean

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
        return new ResponseEntity<>(body, status);
    }

    @Override
    public String getErrorPath() {
        return "/error";
    }
}
```